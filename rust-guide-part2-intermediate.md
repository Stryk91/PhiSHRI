# Part II: Intermediate Topics (Continued)

## 9. Traits: Rust's Interface System

### 9.1 What Are Traits?

Traits define shared behavior in an abstract way. They're similar to interfaces in other languages but more powerful. A trait tells the Rust compiler about functionality a type must provide.

```rust
pub trait Summary {
    fn summarize(&self) -> String;
}
```

This trait defines a method signature that implementing types must provide.

### 9.2 Implementing Traits

Implement a trait for a type using the `impl Trait for Type` syntax:

```rust
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
```

Now both types can use the `summarize` method:

```rust
fn main() {
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        retweet: false,
    };
    
    println!("1 new tweet: {}", tweet.summarize());
}
```

### 9.3 Default Implementations

Traits can provide default implementations:

```rust
pub trait Summary {
    fn summarize_author(&self) -> String;
    
    fn summarize(&self) -> String {
        format!("(Read more from {}...)", self.summarize_author())
    }
}
```

Types can use the default or override it:

```rust
impl Summary for Tweet {
    fn summarize_author(&self) -> String {
        format!("@{}", self.username)
    }
    // Uses default summarize implementation
}
```

Default implementations can call other methods in the trait, even if those methods don't have default implementations.

### 9.4 Traits as Parameters

Use traits to accept any type that implements a trait:

```rust
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}
```

This is syntax sugar for trait bounds:

```rust
pub fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}
```

### 9.5 Multiple Trait Bounds

Specify multiple trait bounds with `+`:

```rust
pub fn notify(item: &(impl Summary + Display)) {
    // item must implement both Summary and Display
}

// Or with trait bound syntax:
pub fn notify<T: Summary + Display>(item: &T) {
    // ...
}
```

### 9.6 Where Clauses

For complex trait bounds, use `where` clauses for readability:

```rust
// Hard to read:
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {
    // ...
}

// Better:
fn some_function<T, U>(t: &T, u: &U) -> i32
where
    T: Display + Clone,
    U: Clone + Debug,
{
    // ...
}
```

### 9.7 Returning Types That Implement Traits

Return any type that implements a trait:

```rust
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        retweet: false,
    }
}
```

**Important Limitation**: You can only return a single concrete type. This won't work:

```rust
fn returns_summarizable(switch: bool) -> impl Summary {
    if switch {
        NewsArticle { /* ... */ }
    } else {
        Tweet { /* ... */ } // ERROR: different types
    }
}
```

For this, you need trait objects (covered later).

### 9.8 Trait Bounds with Conditional Implementation

Implement methods conditionally based on trait bounds:

```rust
use std::fmt::Display;

struct Pair<T> {
    x: T,
    y: T,
}

impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self { x, y }
    }
}

impl<T: Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.x >= self.y {
            println!("The largest member is x = {}", self.x);
        } else {
            println!("The largest member is y = {}", self.y);
        }
    }
}
```

The `cmp_display` method is only available when `T` implements both `Display` and `PartialOrd`.

### 9.9 Blanket Implementations

Implement a trait for any type that satisfies trait bounds:

```rust
impl<T: Display> ToString for T {
    fn to_string(&self) -> String {
        // ...
    }
}
```

This implements `ToString` for any type that implements `Display`. This is why you can call `.to_string()` on integers, floats, etc.

### 9.10 Orphan Rule

You can implement a trait for a type only if either the trait or the type is local to your crate. This is called the **orphan rule** because the parent type is not present.

```rust
// OK: Display is from std, but Vec<String> uses our type
impl Display for Vec<String> {
    // ...
}

// ERROR: Both Display and i32 are from std
impl Display for i32 {
    // ...
}
```

**Why this rule exists**: It prevents two crates from implementing the same trait for the same type, which would cause conflicts.

### 9.11 Supertraits

Traits can depend on other traits:

```rust
use std::fmt;

trait OutlinePrint: fmt::Display {
    fn outline_print(&self) {
        let output = self.to_string();
        let len = output.len();
        println!("{}", "*".repeat(len + 4));
        println!("*{}*", " ".repeat(len + 2));
        println!("* {} *", output);
        println!("*{}*", " ".repeat(len + 2));
        println!("{}", "*".repeat(len + 4));
    }
}
```

Any type implementing `OutlinePrint` must also implement `Display`.

### 9.12 Associated Types

Associated types connect a type placeholder with a trait:

```rust
pub trait Iterator {
    type Item;
    
    fn next(&mut self) -> Option<Self::Item>;
}
```

Implement it:

```rust
struct Counter {
    count: u32,
}

impl Iterator for Counter {
    type Item = u32;
    
    fn next(&mut self) -> Option<Self::Item> {
        self.count += 1;
        if self.count < 6 {
            Some(self.count)
        } else {
            None
        }
    }
}
```

**Associated Types vs Generics**: Associated types mean you can only implement the trait once per type. Generics allow multiple implementations.

```rust
// With generics (can implement multiple times):
trait Iterator<T> {
    fn next(&mut self) -> Option<T>;
}

// With associated types (can implement only once):
trait Iterator {
    type Item;
    fn next(&mut self) -> Option<Self::Item>;
}
```

### 9.13 Operator Overloading

Rust allows operator overloading through traits in `std::ops`:

```rust
use std::ops::Add;

#[derive(Debug, Copy, Clone, PartialEq)]
struct Point {
    x: i32,
    y: i32,
}

impl Add for Point {
    type Output = Point;
    
    fn add(self, other: Point) -> Point {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

fn main() {
    let p1 = Point { x: 1, y: 0 };
    let p2 = Point { x: 2, y: 3 };
    let p3 = p1 + p2;
    println!("{:?}", p3); // Point { x: 3, y: 3 }
}
```

### 9.14 Fully Qualified Syntax

When multiple traits define methods with the same name:

```rust
trait Pilot {
    fn fly(&self);
}

trait Wizard {
    fn fly(&self);
}

struct Human;

impl Pilot for Human {
    fn fly(&self) {
        println!("This is your captain speaking.");
    }
}

impl Wizard for Human {
    fn fly(&self) {
        println!("Up!");
    }
}

impl Human {
    fn fly(&self) {
        println!("*waving arms furiously*");
    }
}

fn main() {
    let person = Human;
    Pilot::fly(&person);  // Calls Pilot's fly
    Wizard::fly(&person); // Calls Wizard's fly
    person.fly();         // Calls Human's fly
}
```

For associated functions without `self`:

```rust
trait Animal {
    fn baby_name() -> String;
}

struct Dog;

impl Dog {
    fn baby_name() -> String {
        String::from("Spot")
    }
}

impl Animal for Dog {
    fn baby_name() -> String {
        String::from("puppy")
    }
}

fn main() {
    println!("A baby dog is called a {}", Dog::baby_name());
    println!("A baby dog is called a {}", <Dog as Animal>::baby_name());
}
```

### 9.15 Practical Example: Building a Plugin System

Let's use traits to build a flexible plugin system:

```rust
use std::collections::HashMap;

// Core trait that all plugins must implement
trait Plugin: Send + Sync {
    fn name(&self) -> &str;
    fn version(&self) -> &str;
    fn execute(&self, input: &str) -> Result<String, String>;
}

// Example plugins
struct UppercasePlugin;

impl Plugin for UppercasePlugin {
    fn name(&self) -> &str {
        "uppercase"
    }
    
    fn version(&self) -> &str {
        "1.0.0"
    }
    
    fn execute(&self, input: &str) -> Result<String, String> {
        Ok(input.to_uppercase())
    }
}

struct ReversePlugin;

impl Plugin for ReversePlugin {
    fn name(&self) -> &str {
        "reverse"
    }
    
    fn version(&self) -> &str {
        "1.0.0"
    }
    
    fn execute(&self, input: &str) -> Result<String, String> {
        Ok(input.chars().rev().collect())
    }
}

// Plugin manager
struct PluginManager {
    plugins: HashMap<String, Box<dyn Plugin>>,
}

impl PluginManager {
    fn new() -> Self {
        PluginManager {
            plugins: HashMap::new(),
        }
    }
    
    fn register(&mut self, plugin: Box<dyn Plugin>) {
        let name = plugin.name().to_string();
        self.plugins.insert(name, plugin);
    }
    
    fn execute(&self, plugin_name: &str, input: &str) -> Result<String, String> {
        match self.plugins.get(plugin_name) {
            Some(plugin) => plugin.execute(input),
            None => Err(format!("Plugin '{}' not found", plugin_name)),
        }
    }
    
    fn list_plugins(&self) {
        for plugin in self.plugins.values() {
            println!("{} v{}", plugin.name(), plugin.version());
        }
    }
}

fn main() {
    let mut manager = PluginManager::new();
    manager.register(Box::new(UppercasePlugin));
    manager.register(Box::new(ReversePlugin));
    
    manager.list_plugins();
    
    match manager.execute("uppercase", "hello world") {
        Ok(result) => println!("Result: {}", result),
        Err(e) => eprintln!("Error: {}", e),
    }
    
    match manager.execute("reverse", "hello world") {
        Ok(result) => println!("Result: {}", result),
        Err(e) => eprintln!("Error: {}", e),
    }
}
```

**Analysis**:
- `Plugin` trait defines the interface all plugins must implement
- `Box<dyn Plugin>` allows storing different plugin types together
- `Send + Sync` bounds ensure plugins are thread-safe
- The system is extensible—new plugins can be added without modifying existing code

### 9.16 Exercises: Traits

**Exercise 1**: Implement a `Shape` trait with an `area` method, then implement it for `Circle`, `Rectangle`, and `Triangle` types.

**Exercise 2**: Create a trait `Drawable` with a `draw` method, and implement it for several types. Then write a function that takes a vector of `Box<dyn Drawable>` and draws all items.

**Exercise 3**: Implement the `Add` trait for a custom `Matrix` type that allows matrix addition.

---

## 10. Generics and Associated Types

### 10.1 Generic Data Types

Generics allow you to write code that works with multiple types:

```rust
struct Point<T> {
    x: T,
    y: T,
}

fn main() {
    let integer_point = Point { x: 5, y: 10 };
    let float_point = Point { x: 1.0, y: 4.0 };
}
```

Multiple type parameters:

```rust
struct Point<T, U> {
    x: T,
    y: U,
}

fn main() {
    let mixed_point = Point { x: 5, y: 4.0 };
}
```

### 10.2 Generic Functions

Functions can be generic over types:

```rust
fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut largest = &list[0];
    
    for item in list {
        if item > largest {
            largest = item;
        }
    }
    
    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];
    let result = largest(&number_list);
    println!("The largest number is {}", result);
    
    let char_list = vec!['y', 'm', 'a', 'q'];
    let result = largest(&char_list);
    println!("The largest char is {}", result);
}
```

### 10.3 Generic Implementations

Implement methods for generic types:

```rust
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

// Implement only for specific types:
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
```

### 10.4 Generic Enums

Enums can be generic:

```rust
enum Option<T> {
    Some(T),
    None,
}

enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

These are so useful they're in the prelude.

### 10.5 Const Generics

Generics can also be over constant values:

```rust
struct ArrayPair<T, const N: usize> {
    left: [T; N],
    right: [T; N],
}

fn main() {
    let pair = ArrayPair {
        left: [1, 2, 3],
        right: [4, 5, 6],
    };
}
```

This is useful for fixed-size arrays and compile-time computations.

### 10.6 Performance of Generics

Rust uses **monomorphization** to make generics zero-cost:

```rust
fn main() {
    let integer = Some(5);
    let float = Some(5.0);
}
```

The compiler generates specialized versions:

```rust
enum Option_i32 {
    Some(i32),
    None,
}

enum Option_f64 {
    Some(f64),
    None,
}

fn main() {
    let integer = Option_i32::Some(5);
    let float = Option_f64::Some(5.0);
}
```

**Result**: No runtime cost for using generics. The generated code is as fast as if you wrote specialized versions manually.

### 10.7 Associated Types in Depth

Associated types are type placeholders in traits:

```rust
pub trait Iterator {
    type Item;
    
    fn next(&mut self) -> Option<Self::Item>;
}
```

**Why use associated types instead of generics?**

With generics:
```rust
pub trait Iterator<T> {
    fn next(&mut self) -> Option<T>;
}
```

You could implement `Iterator<String>` and `Iterator<i32>` for the same type, which is often not what you want.

With associated types, you can only implement the trait once per type, which is usually the desired behavior.

### 10.8 Generic Associated Types (GATs)

GATs allow associated types to be generic:

```rust
trait LendingIterator {
    type Item<'a> where Self: 'a;
    
    fn next<'a>(&'a mut self) -> Option<Self::Item<'a>>;
}
```

This enables patterns like iterators that return references to internal data.

### 10.9 Type Aliases with Generics

Create aliases for complex generic types:

```rust
type Result<T> = std::result::Result<T, std::io::Error>;

fn read_file() -> Result<String> {
    std::fs::read_to_string("file.txt")
}
```

### 10.10 Phantom Types

Use generic parameters that don't appear in fields:

```rust
use std::marker::PhantomData;

struct PhantomTuple<A, B>(A, PhantomData<B>);

fn main() {
    let _tuple1: PhantomTuple<char, f32> = PhantomTuple('Q', PhantomData);
    let _tuple2: PhantomTuple<char, f64> = PhantomTuple('Q', PhantomData);
}
```

Phantom types are useful for:
- Type-level programming
- Encoding state in types
- Zero-cost type safety

### 10.11 Higher-Ranked Trait Bounds (HRTBs)

Express bounds over all lifetimes:

```rust
fn call_with_ref<F>(f: F)
where
    F: for<'a> Fn(&'a i32),
{
    let value = 42;
    f(&value);
}
```

The `for<'a>` syntax means "for all lifetimes 'a".

### 10.12 Practical Example: Generic Data Structure

Let's build a generic binary tree:

```rust
use std::cmp::Ordering;

#[derive(Debug)]
struct BinaryTree<T> {
    value: T,
    left: Option<Box<BinaryTree<T>>>,
    right: Option<Box<BinaryTree<T>>>,
}

impl<T: Ord> BinaryTree<T> {
    fn new(value: T) -> Self {
        BinaryTree {
            value,
            left: None,
            right: None,
        }
    }
    
    fn insert(&mut self, value: T) {
        match value.cmp(&self.value) {
            Ordering::Less => {
                match self.left {
                    Some(ref mut left) => left.insert(value),
                    None => self.left = Some(Box::new(BinaryTree::new(value))),
                }
            }
            Ordering::Greater => {
                match self.right {
                    Some(ref mut right) => right.insert(value),
                    None => self.right = Some(Box::new(BinaryTree::new(value))),
                }
            }
            Ordering::Equal => {} // Value already exists
        }
    }
    
    fn contains(&self, value: &T) -> bool {
        match value.cmp(&self.value) {
            Ordering::Less => {
                self.left.as_ref().map_or(false, |left| left.contains(value))
            }
            Ordering::Greater => {
                self.right.as_ref().map_or(false, |right| right.contains(value))
            }
            Ordering::Equal => true,
        }
    }
    
    fn in_order_traversal(&self) -> Vec<&T> {
        let mut result = Vec::new();
        
        if let Some(ref left) = self.left {
            result.extend(left.in_order_traversal());
        }
        
        result.push(&self.value);
        
        if let Some(ref right) = self.right {
            result.extend(right.in_order_traversal());
        }
        
        result
    }
}

fn main() {
    let mut tree = BinaryTree::new(5);
    tree.insert(3);
    tree.insert(7);
    tree.insert(1);
    tree.insert(9);
    
    println!("Contains 7: {}", tree.contains(&7));
    println!("Contains 4: {}", tree.contains(&4));
    
    let sorted = tree.in_order_traversal();
    println!("In-order: {:?}", sorted);
}
```

**Analysis**:
- Generic over any type `T` that implements `Ord`
- Uses `Box` for heap allocation of child nodes
- Recursive structure enabled by `Box`
- Methods work for any ordered type

### 10.13 Exercises: Generics

**Exercise 1**: Implement a generic `Stack<T>` data structure with `push`, `pop`, and `peek` methods.

**Exercise 2**: Create a generic function that finds the minimum and maximum values in a slice, returning them as a tuple.

**Exercise 3**: Implement a generic `Pair<T, U>` type with a method that swaps the two values.

---

*[Content continues with sections 11-15 covering Smart Pointers, Concurrency, Async Programming, Macros, and Cargo...]*