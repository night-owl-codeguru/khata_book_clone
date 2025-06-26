# Contributing to KhataBook Clone

We welcome contributions to KhataBook Clone and strive to make the contribution process as straightforward and transparent as possible. We encourage various forms of participation including:

- Reporting bugs and security vulnerabilities
- Discussing the current state of the codebase
- Submitting bug fixes and patches
- Proposing new features and enhancements
- Joining the maintainer team

## Getting Started

### Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Add tests if applicable
5. Ensure the test suite passes
6. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
7. Push to the branch (`git push origin feature/AmazingFeature`)
8. Open a Pull Request

### Pull Request Process

1. **Update the README.md** with details of changes to the interface, if applicable
2. **Update the version numbers** in any examples files and the README.md to the new version that this Pull Request would represent
3. **Ensure any install or build dependencies** are removed before the end of the layer when doing a build
4. **Add tests** for any new functionality
5. **Follow the coding standards** outlined below

## Development Setup

### Prerequisites

- Flutter SDK 3.4.1+
- PHP 8.0+
- MySQL 8.0+
- Composer
- Git

### Local Development

1. **Clone your fork**
   ```bash
   git clone https://github.com/yourusername/khata_book_clone.git
   cd khata_book_clone
   ```

2. **Set up the backend**
   ```bash
   cd backend
   composer install
   cp .env.example .env
   # Edit .env with your local database credentials
   ```

3. **Set up the database**
   ```bash
   mysql -u root -p -e "CREATE DATABASE khatabook_dev;"
   mysql -u root -p khatabook_dev < database/schema.sql
   ```

4. **Set up the frontend**
   ```bash
   cd ../frontend
   flutter pub get
   flutter run
   ```

5. **Run tests**
   ```bash
   # Backend tests
   cd backend
   vendor/bin/phpunit
   
   # Frontend tests
   cd ../frontend
   flutter test
   ```

## Coding Standards

### Flutter/Dart

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- Use `flutter format` to format your code
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions small and focused
- Use const constructors where possible

**Example:**
```dart
/// A widget that displays customer information in a card format.
/// 
/// This widget shows the customer's name, balance, and last transaction date.
class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
  });

  final Customer customer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(customer.name),
        subtitle: Text('Balance: ${customer.balance}'),
        onTap: onTap,
      ),
    );
  }
}
```

### PHP

- Follow [PSR-12](https://www.php-fig.org/psr/psr-12/) coding standard
- Use type declarations
- Add PHPDoc comments
- Use meaningful variable and function names
- Keep functions small and focused
- Handle errors appropriately

**Example:**
```php
<?php

declare(strict_types=1);

namespace App\Models;

/**
 * Customer model for handling customer data operations.
 */
class Customer
{
    private int $id;
    private string $name;
    private string $phone;
    private ?string $email;

    /**
     * Create a new customer instance.
     */
    public function __construct(
        int $id,
        string $name,
        string $phone,
        ?string $email = null
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->phone = $phone;
        $this->email = $email;
    }

    /**
     * Get the customer's display name.
     */
    public function getDisplayName(): string
    {
        return $this->name;
    }
}
```

### Database

- Use descriptive table and column names
- Add appropriate indexes
- Use foreign key constraints
- Include created_at and updated_at timestamps
- Use proper data types

## Testing Guidelines

### Frontend Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for complete flows
- Aim for at least 80% test coverage

**Example:**
```dart
testWidgets('CustomerCard displays customer information', (WidgetTester tester) async {
  const customer = Customer(
    id: 1,
    name: 'John Doe',
    balance: 1000.0,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: CustomerCard(customer: customer),
    ),
  );

  expect(find.text('John Doe'), findsOneWidget);
  expect(find.text('Balance: 1000.0'), findsOneWidget);
});
```

### Backend Testing

- Write unit tests for models and utilities
- Write integration tests for API endpoints
- Test both success and error scenarios
- Use factories for test data

**Example:**
```php
<?php

use PHPUnit\Framework\TestCase;
use App\Models\Customer;

class CustomerTest extends TestCase
{
    public function testCustomerCreation(): void
    {
        $customer = new Customer(1, 'John Doe', '+1234567890');
        
        $this->assertEquals('John Doe', $customer->getDisplayName());
        $this->assertEquals('+1234567890', $customer->getPhone());
    }

    public function testCustomerWithEmail(): void
    {
        $customer = new Customer(1, 'John Doe', '+1234567890', 'john@example.com');
        
        $this->assertEquals('john@example.com', $customer->getEmail());
    }
}
```

## Bug Reports

Great Bug Reports tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

**Template:**
```markdown
## Bug Description
A clear and concise description of what the bug is.

## Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
A clear and concise description of what actually happened.

## Screenshots
If applicable, add screenshots to help explain your problem.

## Environment
- OS: [e.g. iOS]
- Flutter Version: [e.g. 3.4.1]
- PHP Version: [e.g. 8.1]
- Device: [e.g. iPhone 13, Pixel 6]

## Additional Context
Add any other context about the problem here.
```

## Feature Requests

We use GitHub issues to track feature requests. When filing a feature request:

1. **Search existing issues** to avoid duplicates
2. **Provide a clear description** of the feature
3. **Explain the use case** and why it would be beneficial
4. **Consider the implementation complexity**

**Template:**
```markdown
## Feature Description
A clear and concise description of what you want to happen.

## Problem Statement
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

## Proposed Solution
A clear and concise description of what you want to happen.

## Alternative Solutions
A clear and concise description of any alternative solutions or features you've considered.

## Additional Context
Add any other context, mockups, or screenshots about the feature request here.

## Implementation Notes
Any technical considerations or implementation details.
```

## Documentation

- Keep documentation up to date
- Use clear and concise language
- Include code examples where appropriate
- Update API documentation for any changes
- Add inline comments for complex logic

## Release Process

1. **Version Bump**: Update version numbers in `pubspec.yaml` and `composer.json`
2. **Changelog**: Update `CHANGELOG.md` with new features and fixes
3. **Testing**: Ensure all tests pass
4. **Documentation**: Update documentation if needed
5. **Release Notes**: Create detailed release notes
6. **Tag**: Create a git tag for the release

## Recognition

Contributors who make significant contributions will be:

- Added to the project's contributors list
- Mentioned in release notes
- Given credit in documentation
- Invited to join the maintainer team (for long-term contributors)

## Questions?

Don't hesitate to reach out if you have questions:

- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For general questions and discussions
- **Email**: dev.khatabook@gmail.com

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

---

**Thank you for contributing to KhataBook Clone!**
