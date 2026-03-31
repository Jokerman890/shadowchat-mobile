# ADR-005: Liquid Glass Design Language and Motion System

- Status: Accepted
- Date: 2026-03-31

## Context
ShadowChat needs a clearly fixed visual and interaction direction before implementation starts.

The product should not look like a generic cross-platform chat template. It should feel premium, modern, layered, tactile, and motion-rich.

The intended design direction is a Liquid-Glass-inspired interface language aligned with the current Apple design shift toward layered, refractive, fluid material behavior, while still remaining implementable on Android in a native-feeling way.

This requires explicit rules for:
- visual hierarchy
- glass/material usage
- blur/translucency behavior
- animation style
- depth and motion
- reduced-motion fallbacks
- platform adaptation

## Decision
Adopt a Liquid-Glass-inspired design system as the default visual language for ShadowChat across iOS and Android.

The product should feel:
- fluid
- layered
- premium
- soft but sharp
- high-depth
- motion-aware
- native on each platform, not copy-pasted

## Visual Design Principles
### 1. Content First, Chrome Second
The UI chrome should frame content rather than dominate it.

Rules:
- chat content remains the visual focus
- controls float above content using layered material treatment
- navigation bars, composer surfaces, sheets, and overlays should feel like translucent glass planes rather than opaque slabs

### 2. Glass Material System
Use a glass-like material vocabulary for key surfaces:
- top bars
- tab bars or bottom navigation
- composer panels
- floating action surfaces
- context menus
- modal sheets
- media preview overlays

Glass surfaces should express:
- translucency
- soft blur
- edge highlights
- subtle internal light separation
- depth over background content

Do not use heavy blur everywhere. Glass treatment should be concentrated on structural chrome and high-value interaction surfaces.

### 3. Rounded Geometry
Use rounded, soft geometry with precise alignment.

Rules:
- larger container radii for primary surfaces
- smaller but related radii for nested controls
- concentric visual relationships between containers and contained controls
- avoid harsh rectangular framing unless functionally necessary

### 4. Depth Model
The interface should feel layered, not flat.

Allowed depth techniques:
- layered translucency
- subtle shadow separation
- controlled scale changes during focus transitions
- parallax-like depth hints only where appropriate
- background defocus for modal and focus states

Depth must remain tasteful and readable. Do not create visual noise.

## Motion System
Motion is a first-class part of the product identity.

### Motion goals
Motion should communicate:
- hierarchy
- continuity
- focus changes
- state transitions
- touch response
- depth and fluidity

Motion must never feel random or game-like.

### Core motion style
Use:
- spring-based motion for tactile transitions
- fluid interpolation for surface movement
- opacity and blur transitions for layer emergence
- coordinated multi-property transitions for major state changes
- subtle scale and elevation responses for touch feedback

Avoid:
- jarring bounce-heavy motion everywhere
- aggressive perpetual animation
- flashy transitions that compete with messaging content
- decorative motion detached from meaning

### Motion categories
#### Microinteractions
Examples:
- button press response
- reaction tap feedback
- toggle transitions
- message selection state
- context menu reveal

Target feel:
- crisp
- short
- tactile
- slightly elastic where appropriate

#### Structural transitions
Examples:
- navigation transitions
- entering a room
- opening profile/details views
- opening media preview
- switching tabs or major sections

Target feel:
- layered
- smooth
- depth-aware
- coordinated between opacity, scale, and position

#### Ambient motion
Examples:
- live blur adaptation
- subtle background shift on modal presentation
- low-level shimmer or refractive response in key hero surfaces if used later

Target feel:
- minimal
- premium
- never distracting

Ambient motion should be used sparingly.

## Platform Adaptation Rules
### iOS
iOS should be the visual reference point for the Liquid-Glass direction.

Expected characteristics:
- strong material-based layering
- smooth spring transitions
- native-feeling blur/translucency usage
- polished sheet and navigation transitions
- haptic-aligned interaction feedback where implemented

### Android
Android should preserve the same product identity while still feeling native.

Rules:
- do not create a fake iOS clone
- use Compose-native animation patterns and Android-appropriate material implementation
- preserve layered translucency, motion richness, and premium depth
- map the design language into Android idioms instead of copying every visual detail literally

## Screen-Level Guidance
### Chat List
- layered top chrome
- search and filters may live in translucent glass containers
- list content remains clean and highly readable
- floating actions should feel elevated and light

### Chat Room
- message timeline remains highly legible and visually calm
- composer area may use prominent glass treatment
- attachment tray, reactions, and overlays should animate fluidly
- background depth should not compromise text contrast

### Sheets and Menus
- use strong depth separation
- animate in with coordinated blur, opacity, and motion
- make dismissal feel soft and physically coherent

### Authentication and Onboarding
- premium, immersive first impression
- restrained but beautiful motion
- glass treatment can be more pronounced here than in dense chat views

## Animation Implementation Guidance
The design system should be implemented as reusable motion and surface tokens, not ad hoc animation per screen.

Define, over time:
- motion tokens
- spring presets
- duration tiers
- blur/material tiers
- elevation/depth tiers
- interaction feedback patterns

Do not hardcode one-off transitions repeatedly across the app.

## Performance Rules
The design direction is motion-rich, but performance remains mandatory.

Rules:
- prefer smoothness over effect count
- avoid stacking expensive blur and shadow operations carelessly
- test motion on realistic device classes
- allow fallback to simplified effects where needed
- dense chat screens must remain responsive first

## Accessibility and Reduced Motion
The default experience should be rich, but the system must respect reduced-motion needs.

Rules:
- decorative motion should be reduced or removed when reduced motion is active
- depth simulation, animated blur, strong parallax, and large scale transitions should have reduced-motion alternatives
- fallback transitions should favor fades, color/opacity changes, and simpler state shifts
- readability and comfort override decorative depth effects

## Consequences
### Positive
- ShadowChat gets a distinct, premium visual identity from the start
- motion becomes a designed system rather than random polish work
- iOS and Android implementations can stay aligned around shared visual principles
- Codex and human contributors get a fixed target for UI and motion decisions

### Costs
- more design-system discipline is required early
- Android adaptation must be done carefully to avoid awkward imitation
- high-blur/high-motion effects require performance review and fallback strategy

## Alternatives Considered
### Generic Material-style chat app with light polish
Rejected because it would not create the desired premium product identity.

### Flat minimal UI with almost no motion
Rejected because it conflicts with the intended tactile and premium visual direction.

### iOS-only premium visual treatment and simpler Android version
Rejected because product identity should remain strong on both platforms, even if adaptation differs.

## Follow-Up
Create supporting docs or tokens for:
- surface/material tiers
- motion token set
- component animation guidelines
- reduced-motion behavior checklist
- screen-by-screen visual rules for chat list, chat room, onboarding, and settings
