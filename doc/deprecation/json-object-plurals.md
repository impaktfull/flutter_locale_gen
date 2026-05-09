# Legacy JSON-object plural format

> Status: still supported — but **not recommended** for new keys. Use [ICU MessageFormat plurals](../../README.md#plural) instead.

Since 8.0.0, locale_gen has supported plurals expressed as a JSON object keyed by CLDR plural categories.

## Syntax

```json
{
  "example_plural": {
    "zero": "You have no items",
    "one": "You have %1$d item",
    "two": "You have 2 items, party!",
    "few": "You have a few items, nice!",
    "many": "You have many items, fantastic!",
    "other": "You have %1$d items"
  }
}
```

This generates a Dart function that takes the count as an argument and returns the correct branch based on the locale's plural rules.

The count argument is **not** automatically substituted into the returned string — interpolate it explicitly with `%1$d` (or any other sprintf marker) inside each branch.

## Rules

- The `other` key is always required.
- The other keys (`zero`, `one`, `two`, `few`, `many`) are optional and are picked according to the active locale's CLDR rules. A language that doesn't use a given category simply ignores that key.

## Why prefer MessageFormat plurals?

ICU MessageFormat plurals are inline, type-safe, and translate naturally for translators familiar with industry-standard tooling. The same example as above in MessageFormat:

```json
{
  "example_plural": "{count, plural, =0 {You have no items} one {You have # item} other {You have # items}}"
}
```

The generated function takes a `num count` named parameter and uses `#` as the substituted count, so you don't need separate sprintf markers per branch.

The JSON-object format remains supported indefinitely for backwards compatibility — there is no plan to remove it.
