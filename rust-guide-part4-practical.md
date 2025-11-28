# Part IV: Practical Applications

## 24. Design Patterns in Rust

### 24.1 Creational Patterns

#### Builder Pattern

```rust
struct Config {
    host: String,
    port: u16,
    timeout: u64,
    retries: u32,
}

struct ConfigBuilder {
    host: Option<String>,
    port: Option<u16>,
    timeout: Option<u64>,
    retries: Option<u32>,
}

impl ConfigBuilder {
    fn new() -> Self {
        ConfigBuilder {
            host: None,
            port: None,
            timeout: None,
            retries: None,
        }
    }
    
    fn host(mut self, host: String) -> Self {
        self.host = Some(host);
        self
    }
    
    fn port(mut self, port: u16) -> Self {
        self.port = Some(port);
        self
    }
    
    fn timeout(mut self, timeout: u64) -> Self {
        self.timeout = Some(timeout);
        self
    }
    
    fn retries(mut self, retries: u32) -> Self {
        self.retries = Some(retries);
        self
    }
    
    fn build(self) -> Result<Config, String> {
        Ok(Config {
            host: self.host.ok_or("host is required")?,
            port: self.port.unwrap_or(8080),
            timeout: self.timeout.unwrap_or(30),
            retries: self.retries.unwrap_or(3),
        })
    }
}

fn main() {
    let config = ConfigBuilder::new()
        .host("localhost".to_string())
        .port(3000)
        .timeout(60)
        .build()
        .unwrap();
}
```

#### Factory Pattern

```rust
trait Shape {
    fn area(&self) -> f64;
}

struct Circle {
    radius: f64,
}

impl Shape for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
}

struct Rectangle {
    width: f64,
    height: f64,
}

impl Shape for Rectangle {
    fn area(&self) -> f64 {
        self.width * self.height
    }
}

enum ShapeType {
    Circle,
    Rectangle,
}

struct ShapeFactory;

impl ShapeFactory {
    fn create(shape_type: ShapeType, params: Vec<f64>) -> Box<dyn Shape> {
        match shape_type {
            ShapeType::Circle => Box::new(Circle { radius: params[0] }),
            ShapeType::Rectangle => Box::new(Rectangle {
                width: params[0],
                height: params[1],
            }),
        }
    }
}
```

### 24.2 Structural Patterns

#### Adapter Pattern

```rust
trait MediaPlayer {
    fn play(&self, audio_type: &str, filename: &str);
}

trait AdvancedMediaPlayer {
    fn play_vlc(&self, filename: &str);
    fn play_mp4(&self, filename: &str);
}

struct VlcPlayer;

impl AdvancedMediaPlayer for VlcPlayer {
    fn play_vlc(&self, filename: &str) {
        println!("Playing vlc file: {}", filename);
    }
    
    fn play_mp4(&self, _filename: &str) {}
}

struct Mp4Player;

impl AdvancedMediaPlayer for Mp4Player {
    fn play_vlc(&self, _filename: &str) {}
    
    fn play_mp4(&self, filename: &str) {
        println!("Playing mp4 file: {}", filename);
    }
}

struct MediaAdapter {
    advanced_player: Box<dyn AdvancedMediaPlayer>,
}

impl MediaAdapter {
    fn new(audio_type: &str) -> Self {
        let advanced_player: Box<dyn AdvancedMediaPlayer> = match audio_type {
            "vlc" => Box::new(VlcPlayer),
            "mp4" => Box::new(Mp4Player),
            _ => panic!("Unsupported format"),
        };
        
        MediaAdapter { advanced_player }
    }
}

impl MediaPlayer for MediaAdapter {
    fn play(&self, audio_type: &str, filename: &str) {
        match audio_type {
            "vlc" => self.advanced_player.play_vlc(filename),
            "mp4" => self.advanced_player.play_mp4(filename),
            _ => println!("Invalid media type"),
        }
    }
}
```

#### Decorator Pattern

```rust
trait Coffee {
    fn cost(&self) -> f64;
    fn description(&self) -> String;
}

struct SimpleCoffee;

impl Coffee for SimpleCoffee {
    fn cost(&self) -> f64 {
        2.0
    }
    
    fn description(&self) -> String {
        "Simple coffee".to_string()
    }
}

struct MilkDecorator {
    coffee: Box<dyn Coffee>,
}

impl Coffee for MilkDecorator {
    fn cost(&self) -> f64 {
        self.coffee.cost() + 0.5
    }
    
    fn description(&self) -> String {
        format!("{}, milk", self.coffee.description())
    }
}

struct SugarDecorator {
    coffee: Box<dyn Coffee>,
}

impl Coffee for SugarDecorator {
    fn cost(&self) -> f64 {
        self.coffee.cost() + 0.2
    }
    
    fn description(&self) -> String {
        format!("{}, sugar", self.coffee.description())
    }
}

fn main() {
    let coffee = SimpleCoffee;
    let coffee = MilkDecorator { coffee: Box::new(coffee) };
    let coffee = SugarDecorator { coffee: Box::new(coffee) };
    
    println!("{}: ${}", coffee.description(), coffee.cost());
}
```

### 24.3 Behavioral Patterns

#### Strategy Pattern

```rust
trait CompressionStrategy {
    fn compress(&self, data: &str) -> String;
}

struct ZipCompression;

impl CompressionStrategy for ZipCompression {
    fn compress(&self, data: &str) -> String {
        format!("ZIP compressed: {}", data)
    }
}

struct RarCompression;

impl CompressionStrategy for RarCompression {
    fn compress(&self, data: &str) -> String {
        format!("RAR compressed: {}", data)
    }
}

struct Compressor {
    strategy: Box<dyn CompressionStrategy>,
}

impl Compressor {
    fn new(strategy: Box<dyn CompressionStrategy>) -> Self {
        Compressor { strategy }
    }
    
    fn compress(&self, data: &str) -> String {
        self.strategy.compress(data)
    }
    
    fn set_strategy(&mut self, strategy: Box<dyn CompressionStrategy>) {
        self.strategy = strategy;
    }
}

fn main() {
    let mut compressor = Compressor::new(Box::new(ZipCompression));
    println!("{}", compressor.compress("Hello World"));
    
    compressor.set_strategy(Box::new(RarCompression));
    println!("{}", compressor.compress("Hello World"));
}
```

#### Observer Pattern

```rust
use std::cell::RefCell;
use std::rc::Rc;

trait Observer {
    fn update(&self, message: &str);
}

struct ConcreteObserver {
    name: String,
}

impl Observer for ConcreteObserver {
    fn update(&self, message: &str) {
        println!("{} received: {}", self.name, message);
    }
}

struct Subject {
    observers: Vec<Rc<dyn Observer>>,
}

impl Subject {
    fn new() -> Self {
        Subject {
            observers: Vec::new(),
        }
    }
    
    fn attach(&mut self, observer: Rc<dyn Observer>) {
        self.observers.push(observer);
    }
    
    fn notify(&self, message: &str) {
        for observer in &self.observers {
            observer.update(message);
        }
    }
}

fn main() {
    let mut subject = Subject::new();
    
    let observer1 = Rc::new(ConcreteObserver {
        name: "Observer 1".to_string(),
    });
    let observer2 = Rc::new(ConcreteObserver {
        name: "Observer 2".to_string(),
    });
    
    subject.attach(observer1);
    subject.attach(observer2);
    
    subject.notify("Hello Observers!");
}
```

### 24.4 Rust-Specific Patterns

#### Newtype Pattern

```rust
struct Meters(f64);
struct Kilometers(f64);

impl From<Kilometers> for Meters {
    fn from(km: Kilometers) -> Self {
        Meters(km.0 * 1000.0)
    }
}

impl From<Meters> for Kilometers {
    fn from(m: Meters) -> Self {
        Kilometers(m.0 / 1000.0)
    }
}
```

#### Type State Pattern

```rust
struct Locked;
struct Unlocked;

struct Door<State> {
    _state: std::marker::PhantomData<State>,
}

impl Door<Locked> {
    fn new() -> Self {
        Door {
            _state: std::marker::PhantomData,
        }
    }
    
    fn unlock(self) -> Door<Unlocked> {
        println!("Door unlocked");
        Door {
            _state: std::marker::PhantomData,
        }
    }
}

impl Door<Unlocked> {
    fn lock(self) -> Door<Locked> {
        println!("Door locked");
        Door {
            _state: std::marker::PhantomData,
        }
    }
    
    fn open(&self) {
        println!("Door opened");
    }
}

fn main() {
    let door = Door::<Locked>::new();
    let door = door.unlock();
    door.open();
    let door = door.lock();
    // door.open(); // Compile error!
}
```

### 24.5 Exercises: Design Patterns

**Exercise 1**: Implement the Command pattern for a text editor with undo/redo functionality.

**Exercise 2**: Create a Chain of Responsibility pattern for request processing.

**Exercise 3**: Implement the Visitor pattern for traversing a tree structure.

---

## 25. Systems Programming

### 25.1 File I/O

```rust
use std::fs::{File, OpenOptions};
use std::io::{self, Read, Write, BufReader, BufRead};

fn read_file(path: &str) -> io::Result<String> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

fn write_file(path: &str, contents: &str) -> io::Result<()> {
    let mut file = File::create(path)?;
    file.write_all(contents.as_bytes())?;
    Ok(())
}

fn append_to_file(path: &str, contents: &str) -> io::Result<()> {
    let mut file = OpenOptions::new()
        .append(true)
        .create(true)
        .open(path)?;
    file.write_all(contents.as_bytes())?;
    Ok(())
}

fn read_lines(path: &str) -> io::Result<Vec<String>> {
    let file = File::open(path)?;
    let reader = BufReader::new(file);
    reader.lines().collect()
}
```

### 25.2 Process Management

```rust
use std::process::{Command, Stdio};
use std::io::Write;

fn run_command() -> std::io::Result<()> {
    let output = Command::new("ls")
        .arg("-la")
        .output()?;
    
    println!("Status: {}", output.status);
    println!("Stdout: {}", String::from_utf8_lossy(&output.stdout));
    println!("Stderr: {}", String::from_utf8_lossy(&output.stderr));
    
    Ok(())
}

fn pipe_commands() -> std::io::Result<()> {
    let mut child = Command::new("echo")
        .arg("Hello, World!")
        .stdout(Stdio::piped())
        .spawn()?;
    
    if let Some(mut stdout) = child.stdout.take() {
        let mut grep = Command::new("grep")
            .arg("World")
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .spawn()?;
        
        if let Some(mut stdin) = grep.stdin.take() {
            std::io::copy(&mut stdout, &mut stdin)?;
        }
        
        let output = grep.wait_with_output()?;
        println!("{}", String::from_utf8_lossy(&output.stdout));
    }
    
    child.wait()?;
    Ok(())
}
```

### 25.3 Network Programming

```rust
use std::net::{TcpListener, TcpStream};
use std::io::{Read, Write};
use std::thread;

fn handle_client(mut stream: TcpStream) {
    let mut buffer = [0; 512];
    
    match stream.read(&mut buffer) {
        Ok(size) => {
            let response = format!("Received {} bytes", size);
            stream.write_all(response.as_bytes()).unwrap();
        }
        Err(e) => eprintln!("Error reading from stream: {}", e),
    }
}

fn run_server() -> std::io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:8080")?;
    println!("Server listening on port 8080");
    
    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                thread::spawn(|| {
                    handle_client(stream);
                });
            }
            Err(e) => eprintln!("Connection failed: {}", e),
        }
    }
    
    Ok(())
}

fn run_client() -> std::io::Result<()> {
    let mut stream = TcpStream::connect("127.0.0.1:8080")?;
    
    stream.write_all(b"Hello, Server!")?;
    
    let mut buffer = [0; 512];
    let size = stream.read(&mut buffer)?;
    
    println!("Response: {}", String::from_utf8_lossy(&buffer[..size]));
    
    Ok(())
}
```

### 25.4 Memory-Mapped Files

```rust
use memmap2::MmapOptions;
use std::fs::File;

fn read_mmap(path: &str) -> std::io::Result<()> {
    let file = File::open(path)?;
    let mmap = unsafe { MmapOptions::new().map(&file)? };
    
    println!("File size: {} bytes", mmap.len());
    println!("First 10 bytes: {:?}", &mmap[..10.min(mmap.len())]);
    
    Ok(())
}
```

### 25.5 Exercises: Systems Programming

**Exercise 1**: Implement a file watcher that monitors a directory for changes.

**Exercise 2**: Create a simple HTTP server from scratch using TCP sockets.

**Exercise 3**: Build a process monitor that tracks CPU and memory usage.

---

## 26. Web Development with Rust

### 26.1 Actix-Web Example

```rust
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct User {
    id: u32,
    name: String,
    email: String,
}

async fn get_user(user_id: web::Path<u32>) -> impl Responder {
    let user = User {
        id: *user_id,
        name: "John Doe".to_string(),
        email: "john@example.com".to_string(),
    };
    
    HttpResponse::Ok().json(user)
}

async fn create_user(user: web::Json<User>) -> impl Responder {
    println!("Creating user: {:?}", user.name);
    HttpResponse::Created().json(user.into_inner())
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/users/{id}", web::get().to(get_user))
            .route("/users", web::post().to(create_user))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
```

### 26.2 Axum Example

```rust
use axum::{
    extract::Path,
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct User {
    id: u32,
    name: String,
}

async fn get_user(Path(id): Path<u32>) -> Json<User> {
    Json(User {
        id,
        name: "John Doe".to_string(),
    })
}

async fn create_user(Json(user): Json<User>) -> Json<User> {
    Json(user)
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/users/:id", get(get_user))
        .route("/users", post(create_user));
    
    axum::Server::bind(&"127.0.0.1:3000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
```

### 26.3 Database Integration

```rust
use sqlx::{PgPool, FromRow};
use serde::{Deserialize, Serialize};

#[derive(Debug, FromRow, Serialize, Deserialize)]
struct User {
    id: i32,
    name: String,
    email: String,
}

async fn get_users(pool: &PgPool) -> Result<Vec<User>, sqlx::Error> {
    let users = sqlx::query_as::<_, User>("SELECT id, name, email FROM users")
        .fetch_all(pool)
        .await?;
    
    Ok(users)
}

async fn create_user(pool: &PgPool, name: &str, email: &str) -> Result<User, sqlx::Error> {
    let user = sqlx::query_as::<_, User>(
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, name, email"
    )
    .bind(name)
    .bind(email)
    .fetch_one(pool)
    .await?;
    
    Ok(user)
}

#[tokio::main]
async fn main() -> Result<(), sqlx::Error> {
    let pool = PgPool::connect("postgres://user:password@localhost/mydb").await?;
    
    let users = get_users(&pool).await?;
    println!("Users: {:?}", users);
    
    let new_user = create_user(&pool, "Alice", "alice@example.com").await?;
    println!("Created user: {:?}", new_user);
    
    Ok(())
}
```

### 26.4 Exercises: Web Development

**Exercise 1**: Build a RESTful API with CRUD operations for a blog.

**Exercise 2**: Implement authentication and authorization middleware.

**Exercise 3**: Create a WebSocket server for real-time chat.

---

## 27. Performance Profiling and Optimization

### 27.1 Benchmarking with Criterion

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn fibonacci_recursive(n: u64) -> u64 {
    match n {
        0 => 0,
        1 => 1,
        n => fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2),
    }
}

fn fibonacci_iterative(n: u64) -> u64 {
    let mut a = 0;
    let mut b = 1;
    
    for _ in 0..n {
        let temp = a;
        a = b;
        b = temp + b;
    }
    
    a
}

fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("fib recursive 20", |b| {
        b.iter(|| fibonacci_recursive(black_box(20)))
    });
    
    c.bench_function("fib iterative 20", |b| {
        b.iter(|| fibonacci_iterative(black_box(20)))
    });
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
```

### 27.2 Profiling with perf

```bash
# Build with debug symbols
cargo build --release

# Profile with perf
perf record --call-graph=dwarf ./target/release/myapp

# View results
perf report
```

### 27.3 Memory Profiling

```rust
use std::alloc::{GlobalAlloc, Layout, System};
use std::sync::atomic::{AtomicUsize, Ordering};

struct CountingAllocator;

static ALLOCATED: AtomicUsize = AtomicUsize::new(0);

unsafe impl GlobalAlloc for CountingAllocator {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        let ret = System.alloc(layout);
        if !ret.is_null() {
            ALLOCATED.fetch_add(layout.size(), Ordering::SeqCst);
        }
        ret
    }
    
    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        System.dealloc(ptr, layout);
        ALLOCATED.fetch_sub(layout.size(), Ordering::SeqCst);
    }
}

#[global_allocator]
static GLOBAL: CountingAllocator = CountingAllocator;

fn main() {
    let before = ALLOCATED.load(Ordering::SeqCst);
    
    let v = vec![1, 2, 3, 4, 5];
    
    let after = ALLOCATED.load(Ordering::SeqCst);
    
    println!("Allocated: {} bytes", after - before);
}
```

### 27.4 Optimization Techniques

```rust
// Use iterators instead of loops
fn sum_squares_loop(numbers: &[i32]) -> i32 {
    let mut sum = 0;
    for &n in numbers {
        sum += n * n;
    }
    sum
}

fn sum_squares_iter(numbers: &[i32]) -> i32 {
    numbers.iter().map(|&n| n * n).sum()
}

// Avoid unnecessary allocations
fn process_string_bad(s: &str) -> String {
    let mut result = String::new();
    for c in s.chars() {
        result.push(c.to_uppercase().next().unwrap());
    }
    result
}

fn process_string_good(s: &str) -> String {
    s.chars()
        .map(|c| c.to_uppercase().next().unwrap())
        .collect()
}

// Use appropriate data structures
use std::collections::HashMap;

fn count_words_vec(words: &[String]) -> Vec<(String, usize)> {
    let mut counts = HashMap::new();
    for word in words {
        *counts.entry(word.clone()).or_insert(0) += 1;
    }
    counts.into_iter().collect()
}
```

### 27.5 Exercises: Performance

**Exercise 1**: Profile a program and identify bottlenecks.

**Exercise 2**: Optimize a sorting algorithm using benchmarks.

**Exercise 3**: Reduce memory allocations in a data processing pipeline.

---

## 28. Testing Strategies

### 28.1 Unit Tests

```rust
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_add() {
        assert_eq!(add(2, 2), 4);
    }
    
    #[test]
    fn test_add_negative() {
        assert_eq!(add(-1, 1), 0);
    }
    
    #[test]
    #[should_panic(expected = "overflow")]
    fn test_overflow() {
        add(i32::MAX, 1);
    }
}
```

### 28.2 Integration Tests

```rust
// tests/integration_test.rs
use my_crate::*;

#[test]
fn test_integration() {
    let result = complex_operation();
    assert!(result.is_ok());
}
```

### 28.3 Property-Based Testing

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_reverse_reverse(s in "\\PC*") {
        let reversed: String = s.chars().rev().collect();
        let double_reversed: String = reversed.chars().rev().collect();
        prop_assert_eq!(s, double_reversed);
    }
}
```

### 28.4 Mocking

```rust
trait Database {
    fn get_user(&self, id: u32) -> Option<String>;
}

struct MockDatabase {
    users: std::collections::HashMap<u32, String>,
}

impl Database for MockDatabase {
    fn get_user(&self, id: u32) -> Option<String> {
        self.users.get(&id).cloned()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_with_mock() {
        let mut mock = MockDatabase {
            users: std::collections::HashMap::new(),
        };
        mock.users.insert(1, "Alice".to_string());
        
        assert_eq!(mock.get_user(1), Some("Alice".to_string()));
        assert_eq!(mock.get_user(2), None);
    }
}
```

### 28.5 Exercises: Testing

**Exercise 1**: Write comprehensive unit tests for a calculator module.

**Exercise 2**: Implement integration tests for a REST API.

**Exercise 3**: Use property-based testing to verify sorting algorithms.

---

## 29. Common Pitfalls and Best Practices

### 29.1 Common Pitfalls

#### Pitfall 1: Fighting the Borrow Checker

```rust
// Bad: Trying to hold multiple mutable references
fn bad_example() {
    let mut v = vec![1, 2, 3];
    let first = &mut v[0];
    v.push(4); // ERROR
    *first += 1;
}

// Good: Limit scope of borrows
fn good_example() {
    let mut v = vec![1, 2, 3];
    {
        let first = &mut v[0];
        *first += 1;
    }
    v.push(4); // OK
}
```

#### Pitfall 2: Unnecessary Cloning

```rust
// Bad: Cloning when not needed
fn bad_process(s: String) -> String {
    let s_clone = s.clone();
    s_clone.to_uppercase()
}

// Good: Take ownership or use references
fn good_process(s: String) -> String {
    s.to_uppercase()
}

fn good_process_ref(s: &str) -> String {
    s.to_uppercase()
}
```

#### Pitfall 3: Ignoring Errors

```rust
// Bad: Unwrapping everywhere
fn bad_read_file(path: &str) -> String {
    std::fs::read_to_string(path).unwrap()
}

// Good: Proper error handling
fn good_read_file(path: &str) -> std::io::Result<String> {
    std::fs::read_to_string(path)
}
```

### 29.2 Best Practices

#### Practice 1: Use Type System for Correctness

```rust
struct UserId(u32);
struct ProductId(u32);

fn get_user(id: UserId) -> User {
    // Can't accidentally pass ProductId
}
```

#### Practice 2: Prefer Iterators

```rust
// Good: Functional style with iterators
fn process_numbers(numbers: &[i32]) -> Vec<i32> {
    numbers.iter()
        .filter(|&&n| n > 0)
        .map(|&n| n * 2)
        .collect()
}
```

#### Practice 3: Document Public APIs

```rust
/// Calculates the factorial of a number.
///
/// # Arguments
///
/// * `n` - The number to calculate factorial for
///
/// # Examples
///
/// ```
/// let result = factorial(5);
/// assert_eq!(result, 120);
/// ```
///
/// # Panics
///
/// Panics if `n` is greater than 20 (overflow).
pub fn factorial(n: u64) -> u64 {
    (1..=n).product()
}
```

#### Practice 4: Use Cargo Features

```toml
[features]
default = ["std"]
std = []
serde_support = ["serde"]

[dependencies]
serde = { version = "1.0", optional = true }
```

### 29.3 Exercises: Best Practices

**Exercise 1**: Refactor code to eliminate unnecessary clones.

**Exercise 2**: Add comprehensive documentation to a module.

**Exercise 3**: Implement proper error handling throughout a project.

---

*[End of Part IV]*