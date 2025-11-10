# Contributing to Railway PostgreSQL + PostGIS + pgvector

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Ways to Contribute

- Report bugs and issues
- Suggest new features or improvements
- Submit pull requests
- Improve documentation
- Test new PostgreSQL, PostGIS, or pgvector versions

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/railway-postgis-pgvector.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test thoroughly (see BUILD_AND_TEST.md)
6. Commit your changes: `git commit -m "Description of changes"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Workflow

### Making Changes

1. **Small, focused changes**: Keep PRs small and focused on a single issue
2. **Test locally**: Always test your changes before submitting
3. **Follow existing patterns**: Match the style and structure of existing code
4. **Update documentation**: Update README.md and other docs as needed

### Testing Requirements

Before submitting a PR, ensure:

- [ ] Docker image builds successfully
- [ ] All extensions load correctly
- [ ] Test suite passes (`./test.sh`)
- [ ] Documentation is updated
- [ ] No breaking changes (unless explicitly discussed)

### Running Tests

```bash
# Build the image
docker build -t railway-postgis-pgvector:test .

# Start container
docker run -d --name test-pg \
  -e POSTGRES_PASSWORD=testpass \
  -p 5432:5432 \
  railway-postgis-pgvector:test

# Wait for startup
sleep 10

# Run tests
./test.sh

# Clean up
docker stop test-pg && docker rm test-pg
```

## Version Updates

When updating component versions:

1. **Check compatibility**: Ensure versions are compatible with each other
2. **Update Dockerfile**: Change version environment variables
3. **Test thoroughly**: Run full test suite
4. **Update README**: Update version numbers in documentation
5. **Note breaking changes**: Document any breaking changes in PR description

## Code Review Process

1. Automated tests must pass
2. At least one maintainer approval required
3. Address review comments promptly
4. Keep discussions focused and professional

## Reporting Issues

When reporting bugs:

- Use the issue template (if available)
- Include version information
- Provide steps to reproduce
- Include error messages and logs
- Describe expected vs actual behavior

Example:
```
**Environment:**
- PostgreSQL version: 18
- Docker version: 24.0.0
- Host OS: Ubuntu 22.04

**Steps to reproduce:**
1. Build image with `docker build -t test .`
2. Run container with `docker run ...`
3. Execute query `SELECT ...`

**Expected behavior:**
Query should return ...

**Actual behavior:**
Error: ...

**Logs:**
```
[paste logs here]
```
```

## Pull Request Guidelines

### PR Title

Use clear, descriptive titles:
- ✅ "Update pgvector to version 0.8.0"
- ✅ "Fix PostGIS extension initialization"
- ❌ "Update"
- ❌ "Fix bug"

### PR Description

Include:
- What changes were made
- Why the changes were needed
- How to test the changes
- Any breaking changes
- Related issues (use "Fixes #123" to auto-close)

### Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Keep first line under 72 characters
- Reference issues when applicable
- Separate subject from body with blank line

Example:
```
Add support for pgvector 0.8.0

- Update Dockerfile to install pgvector 0.8.0
- Add tests for new vector operations
- Update README with new features

Fixes #123
```

## Code Style

### Dockerfile
- Use multi-line RUN commands with `\` for readability
- Group related commands
- Clean up in the same layer to reduce image size
- Add comments for complex operations

### Shell Scripts
- Use bash shebang: `#!/bin/bash`
- Enable error handling: `set -e`
- Add comments for complex logic
- Use descriptive variable names

### SQL
- Use uppercase for SQL keywords
- Format for readability
- Add comments for complex queries

## Community Guidelines

- Be respectful and inclusive
- Provide constructive feedback
- Help others when possible
- Stay on topic in discussions

## Questions?

If you have questions:
- Check existing issues and discussions
- Review documentation (README.md, BUILD_AND_TEST.md)
- Open a new issue with the "question" label

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
