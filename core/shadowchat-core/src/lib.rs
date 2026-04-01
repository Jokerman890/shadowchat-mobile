use std::collections::HashSet;

use unicode_normalization::UnicodeNormalization;

uniffi::setup_scaffolding!();

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Enum)]
pub enum ErrorCode {
    InvalidUsername,
    UsernameTaken,
    NetworkUnavailable,
    AuthFailed,
    InternalError,
}

#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error, uniffi::Error)]
pub enum CoreError {
    #[error("Username is invalid: {0}")]
    InvalidUsername(String),
    #[error("Username is not available")]
    UsernameTaken,
    #[error("Network is unavailable")]
    NetworkUnavailable,
    #[error("Authentication failed")]
    AuthFailed,
    #[error("Internal error")]
    InternalError,
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct UsernameValidationResult {
    pub canonical_username: String,
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct AuthRequest {
    pub username_input: String,
    pub phone_number: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct AuthResponse {
    pub user_id: String,
    pub session_state: SessionState,
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Enum)]
pub enum SessionState {
    SignedOut,
    Restoring,
    SignedIn,
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct RoomListEntryPoint {
    pub session_ready: bool,
    pub state: String,
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum UsernameValidationError {
    Empty,
    TooShort,
    TooLong,
    InvalidStart,
    InvalidEnd,
    InvalidCharacters,
    ConsecutiveSeparators,
    Reserved,
}

const MIN_USERNAME_LEN: usize = 3;
const MAX_USERNAME_LEN: usize = 32;
const RESERVED_NAMES: &[&str] = &[
    "admin",
    "administrator",
    "support",
    "security",
    "system",
    "root",
    "null",
    "undefined",
];

#[derive(uniffi::Object)]
pub struct UsernameAvailabilityService {
    taken_usernames: HashSet<String>,
}

#[uniffi::export]
impl UsernameAvailabilityService {
    #[uniffi::constructor]
    pub fn new(taken_usernames: Vec<String>) -> Self {
        Self {
            taken_usernames: taken_usernames.into_iter().collect(),
        }
    }

    pub fn is_username_available(&self, canonical_username: String) -> bool {
        !self.taken_usernames.contains(&canonical_username)
    }
}

#[derive(uniffi::Object)]
pub struct AuthService {
    taken_usernames: HashSet<String>,
}

#[uniffi::export]
impl AuthService {
    #[uniffi::constructor]
    pub fn new(taken_usernames: Vec<String>) -> Self {
        Self {
            taken_usernames: taken_usernames.into_iter().collect(),
        }
    }

    pub fn validate_and_normalize_username(
        &self,
        username_input: String,
    ) -> Result<UsernameValidationResult, CoreError> {
        validate_and_normalize_username(username_input)
    }

    pub fn register_stub(&self, request: AuthRequest) -> Result<AuthResponse, CoreError> {
        let result = validate_and_normalize_username(request.username_input)?;
        if self.taken_usernames.contains(&result.canonical_username) {
            return Err(CoreError::UsernameTaken);
        }

        Ok(AuthResponse {
            user_id: format!("@{}:example.shadowchat", result.canonical_username),
            session_state: SessionState::SignedIn,
        })
    }

    pub fn room_list_entry_point_stub(&self, state: SessionState) -> RoomListEntryPoint {
        RoomListEntryPoint {
            session_ready: state == SessionState::SignedIn,
            state: format!("{:?}", state),
        }
    }
}

#[uniffi::export]
pub fn validate_and_normalize_username(
    username_input: String,
) -> Result<UsernameValidationResult, CoreError> {
    let trimmed = username_input.trim();
    let normalized: String = trimmed.nfkc().collect();
    let canonical = normalized.to_lowercase();

    validate_username_rules(&canonical)
        .map_err(|e| CoreError::InvalidUsername(username_error_message(e).to_string()))?;

    Ok(UsernameValidationResult {
        canonical_username: canonical,
    })
}

fn validate_username_rules(username: &str) -> Result<(), UsernameValidationError> {
    if username.is_empty() {
        return Err(UsernameValidationError::Empty);
    }
    if username.len() < MIN_USERNAME_LEN {
        return Err(UsernameValidationError::TooShort);
    }
    if username.len() > MAX_USERNAME_LEN {
        return Err(UsernameValidationError::TooLong);
    }

    let chars: Vec<char> = username.chars().collect();
    if !is_alphanumeric(chars[0]) {
        return Err(UsernameValidationError::InvalidStart);
    }
    if !is_alphanumeric(*chars.last().unwrap_or(&chars[0])) {
        return Err(UsernameValidationError::InvalidEnd);
    }

    let mut previous_is_separator = false;
    for ch in chars {
        if is_separator(ch) {
            if previous_is_separator {
                return Err(UsernameValidationError::ConsecutiveSeparators);
            }
            previous_is_separator = true;
            continue;
        }

        if !is_alphanumeric(ch) {
            return Err(UsernameValidationError::InvalidCharacters);
        }

        previous_is_separator = false;
    }

    if RESERVED_NAMES.contains(&username) {
        return Err(UsernameValidationError::Reserved);
    }

    Ok(())
}

fn is_alphanumeric(ch: char) -> bool {
    ch.is_ascii_lowercase() || ch.is_ascii_digit()
}

fn is_separator(ch: char) -> bool {
    matches!(ch, '.' | '_' | '-')
}

fn username_error_message(error: UsernameValidationError) -> &'static str {
    match error {
        UsernameValidationError::Empty => "Username is required",
        UsernameValidationError::TooShort => "Username must be at least 3 characters",
        UsernameValidationError::TooLong => "Username must be at most 32 characters",
        UsernameValidationError::InvalidStart => {
            "Username must start with a lowercase letter or digit"
        }
        UsernameValidationError::InvalidEnd => "Username must end with a lowercase letter or digit",
        UsernameValidationError::InvalidCharacters => "Username contains unsupported characters",
        UsernameValidationError::ConsecutiveSeparators => {
            "Username cannot contain consecutive separators"
        }
        UsernameValidationError::Reserved => "Username is reserved",
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normalizes_trim_and_case() {
        let result = validate_and_normalize_username("  Shadow.Chat_01  ".to_string()).unwrap();
        assert_eq!(result.canonical_username, "shadow.chat_01");
    }

    #[test]
    fn normalizes_nfkc_characters() {
        let result = validate_and_normalize_username("Ａlice1".to_string()).unwrap();
        assert_eq!(result.canonical_username, "alice1");
    }

    #[test]
    fn rejects_non_ascii_characters() {
        let err = validate_and_normalize_username("михаил".to_string()).unwrap_err();
        assert!(matches!(err, CoreError::InvalidUsername(_)));
    }

    #[test]
    fn rejects_reserved_names() {
        let err = validate_and_normalize_username("admin".to_string()).unwrap_err();
        assert_eq!(err.to_string(), "Username is invalid: Username is reserved");
    }

    #[test]
    fn rejects_consecutive_separators() {
        let err = validate_and_normalize_username("alice..bob".to_string()).unwrap_err();
        assert_eq!(
            err.to_string(),
            "Username is invalid: Username cannot contain consecutive separators"
        );
    }

    #[test]
    fn availability_contract_flags_taken() {
        let service = AuthService::new(vec!["takenuser".to_string()]);

        let err = service
            .register_stub(AuthRequest {
                username_input: "takenuser".to_string(),
                phone_number: None,
            })
            .unwrap_err();

        assert_eq!(err, CoreError::UsernameTaken);
    }
}
