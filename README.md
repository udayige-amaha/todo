# monkey patching

In Rails, monkey patching is the practice of reopening an existing class or module at runtime to add, modify, or override its behavior. Because Ruby classes are "open," you can change any code—including core Ruby classes like String or third-party gem code—without modifying the original source files. [1, 2, 3, 4, 5] 
## How to Implement a Monkey Patch
While you can technically reopen a class anywhere, doing so directly is considered "unsophisticated" and brittle. Modern best practices recommend using modules and Module#prepend or Module#include for better maintainability. [3, 6, 7, 8] 
## 1. Recommended Approach: Module#prepend
Using prepend allows your patch to sit "above" the original class in the inheritance chain, meaning you can call super to execute the original method. [3, 7] 
```
# lib/core_extensions/string/shout.rb
module CoreExtensions
  module String
    module Shout
      def shout
        "#{upcase}!!!"
      end
    end
  end
end

# Apply the patch
String.prepend(CoreExtensions::String::Shout)
```
## 2. Where to Put the Code

* config/initializers/: This is the standard location for small patches. Files here are automatically executed when the app boots.
* lib/: For larger extensions, use a directory like lib/core_extensions/ and manually require them in an initializer. [6, 7, 9, 10, 11] 

## Common Use Cases

* Bug Fixes: Temporarily fixing a bug in a gem while waiting for an official update.
* Adding Functionality: Extending core classes with helper methods (e.g., adding a specialized formatting method to DateTime).
* Backporting: Adding features from a newer version of Rails to an older one. [1, 3, 4, 12, 13] 

## Risks and Dangers
Monkey patching is powerful but can be dangerous if misused: [1, 3, 11] 

* Upgrade Paralysis: Patches often rely on private APIs that may change in future Rails versions, making upgrades difficult.
* Global Impact: Changes affect every instance of the class across the entire application, which can cause unexpected side effects in other gems.
* Silent Failures: If the patched method's internal implementation changes, your patch might continue to run but produce incorrect results without raising errors. [1, 3, 4, 11, 14] 

## Best Practices for "Responsible" Patching

   1. Version Checks: Wrap your patch in a check (e.g., if Rails.version == '7.0.1') to ensure it doesn't run on incompatible versions.
   2. Naming: Use descriptive module names and file paths (avoid generic names like monkey_patches.rb).
   3. Documentation: Clearly document why the patch exists and link to any relevant upstream issues or PRs.
   4. Testing: Always write tests for the patched behavior so you know immediately if an upgrade breaks it. [3, 6, 11, 12] 

The best way to extend a class in modern Ruby/Rails—especially if you are overriding an existing method—is using Module#prepend.
Unlike include, which places your code under the class in the hierarchy, prepend places your code in front of it. This allows you to modify a method and use super to trigger the original logic, acting like a "wrapper."
## The "Pro" Pattern: Prepend + ActiveSupport::Concern
This is the cleanest approach because it’s easy to debug, supports super, and follows Rails conventions.
## 1. Define the extension
```
Create a file in lib/core_extensions/string/formatting.rb:

module CoreExtensions
  module String
    module Formatting
      # We want to change how 'capitalize' works
      def capitalize
        "✨ " + super + " ✨"
      end

      # We can also add entirely new methods
      def shout
        "#{self.upcase}!!"
      end
    end
  endend
```
## 2. Apply it via an Initializer
```
Create config/initializers/core_extensions.rb:

# Reopen the class once and prepend our module
String.prepend(CoreExtensions::String::Formatting)
```

## Why this is the "Best" way:

   1. Supports super: You don't have to rewrite the original method's logic; you just "decorate" it.
   2. Clean Ancestry: If you run "hi".class.ancestors, your module appears before String, making it clear why the behavior changed.
   3. No Naming Collisions: By using prepend, you don't accidentally wipe out the original method definition.
   4. Rails Standard: This mirrors how Rails itself extends Ruby core classes (via ActiveSupport).

The difference lies in where the code lives and how Rails loads it. Standard Ruby classes (like String or Array) are globally available, while Rails-specific classes (like ActiveRecord::Base or your models) are part of the framework's complex inheritance and autoloading system. [1] 
## 1. Extending Standard Ruby Classes
Standard classes are "open," meaning you can reopen them globally. In Rails, you typically do this via an initializer.

* Goal: Add a helper to every string in the app.
* Best Practice: Use prepend or include so you don't overwrite existing methods and can see the extension in the [ancestors chain](https://stackoverflow.com/questions/15383878/what-is-the-difference-between-include-and-prepend-in-ruby). [2] 
```
# config/initializers/string_extensions.rbmodule StringShouter
  def shout
    "#{self.upcase}!!!"
  endend

String.include(StringShouter)# Usage: "hello".shout => "HELLO!!!"
```
## 2. Extending Rails-specific Classes (ActiveRecord)
For Rails classes, the "best way" is to use [ActiveSupport::Concern](https://stackoverflow.com/questions/2328984/rails-extending-activerecordbase). This utility handles the complexity of adding both instance methods and class methods (like scopes) simultaneously. [3, 4] 

* Goal: Add a published scope and a formatted_date method to models.
* Implementation: Create a reusable module in lib/ or app/models/concerns/. [4] 
```
# app/models/concerns/publishable.rbmodule Publishable
  extend ActiveSupport::Concern

  # Logic added as class methods (e.g., Post.published)
  included do
    scope :published, -> { where(published: true) }
  end

  # Logic added as instance methods (e.g., post.formatted_date)
  def formatted_date
    created_at.strftime("%B %d, %Y")
  endend
# In your model:class Post < ApplicationRecord
  include Publishableend
```

## Key Differences Summary

| Feature | Standard Ruby Class | Rails-specific (ActiveRecord) |
|---|---|---|
| Location | config/initializers/ | app/models/concerns/ |
| Impact | Global (affects every string/array) | Scoped (only models you "include" it in) |
| Methods | Usually instance methods | Mixed (instance + class methods via Concern) |
| Upgradability | High risk; core methods may change | Lower risk; targets your own logic |
