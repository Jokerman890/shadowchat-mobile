//! Shared core bootstrap crate for ShadowChat.
//! This crate intentionally starts small and grows alongside real product slices.

/// Normalizes a username candidate for uniqueness checks.
///
/// Rules for this bootstrap implementation:
/// - trim leading/trailing whitespace
/// - lowercase using Unicode-aware conversion
/// - preserve interior characters
pub fn normalize_username(input: &str) -> String {
    input.trim().to_lowercase()
}

#[cfg(test)]
mod tests {
    use super::normalize_username;

    #[test]
    fn normalizes_case_and_whitespace() {
        assert_eq!(normalize_username("  ShadowUser  "), "shadowuser");
    }

    #[test]
    fn preserves_interior_characters() {
        assert_eq!(normalize_username("User_Name-01"), "user_name-01");
    }
}
