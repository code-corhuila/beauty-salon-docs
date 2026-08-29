# Accessibility

Accessibility is a **requirement**, not a nice-to-have. These rules are checked before a
story is Done.

## Rules

- Every interactive element has an accessible label (screen-reader text).
- Minimum touch target: **44×44 pt** (iOS) / **48×48 dp** (Android).
- Text scales with the OS font-size setting — never hardcode absolute sizes for body text.
- Color contrast meets **WCAG AA**: 4.5:1 for body text, 3:1 for large text and icons.
- Do not convey meaning by color alone — pair with text, icon, or shape.
- Screens are fully navigable and readable by the platform screen reader (VoiceOver / TalkBack).
- Respect "reduce motion" — provide non-animated alternatives.
- Focus order follows reading order; modals trap focus and restore it on dismiss.

## Verification checklist

- [ ] Screen-reader pass (VoiceOver + TalkBack) on the primary flow.
- [ ] Largest OS font size does not break layout.
- [ ] Contrast checked on light and dark themes.
- [ ] All actionable targets meet the minimum size.
- [ ] "Reduce motion" honored.
