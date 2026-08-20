# Contributing

Thanks for your interest in improving `jekyll-livid`.

## Before submitting changes

1. Keep the scope narrow and focused on Livid video embedding.
2. Add or update tests for behavior changes.
3. Run the test suite before opening a pull request.

## Local development

```bash
bundle install
ruby -Ilib -Itest test/livid_tag_test.rb
```

## Design philosophy

- One tag, one job: embed Livid videos cleanly
- All advanced parameters passed through to the iframe src
- No dependencies beyond Jekyll itself
