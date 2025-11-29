# Part III: Advanced Concepts

## 16. Unsafe Rust

### 16.1 Understanding Unsafe

Unsafe Rust exists because static analysis is conservative. Sometimes you know your code is safe, but the compiler can't verify it. Unsafe Rust gives you five superpowers:

1. Dereference raw pointers
2. Call unsafe functions or methods
3. Access or modify mutable static variables
4. Implement unsafe traits
5. Access fields of unions

**Important**: Unsafe doesn't turn off the borrow checker or disable other safety checks. It only allows these five operations.

### 16.2 Raw Pointers

Raw pointers can be immutable (`*const T`) or mutable (`*mut T`):

```rust
fn main() {
    let mut num = 5;
    
    let r1 = &num as *const i32;
    let r2 = &mut num as *mut i32;
    
    unsafe {
        println!("r1 is: {}", *r1);
        println!("r2 is: {}", *r2);
    }
}
```

**Key Differences from References**:
- Can ignore borrowing rules
- Aren't guaranteed to point to valid memory
- Can be null
- Don't implement automatic cleanup

### 16.3 Calling Unsafe Functions

Mark functions as unsafe when they have requirements the compiler can't verify:

```rust
unsafe fn dangerous() {
    // Unsafe operations
}

fn main() {
    unsafe {
        dangerous();
    }
}
```

### 16.4 Creating Safe Abstractions

Wrap unsafe code in safe abstractions:

```rust
use std::slice;

fn split_at_mut(slice: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    let len = slice.len();
    let ptr = slice.as_mut_ptr();
    
    assert!(mid <= len);
    
    unsafe {
        (
            slice::from_raw_parts_mut(ptr, mid),
            slice::from_raw_parts_mut(ptr.add(mid), len - mid),
        )
    }
}

fn main() {
    let mut v = vec![1, 2, 3, 4, 5, 6];
    let (left, right) = split_at_mut(&mut v, 3);
    
    println!("Left: {:?}", left);
    println!("Right: {:?}", right);
}
```

**Analysis**: The function is safe to call because we verify the invariants (mid <= len) before using unsafe code.

### 16.5 Using extern Functions

Call functions from other languages:

```rust
extern "C" {
    fn abs(input: i32) -> i32;
}

fn main() {
    unsafe {
        println!("Absolute value of -3 according to C: {}", abs(-3));
    }
}
```

### 16.6 Accessing Mutable Static Variables

Static variables can be mutable, but accessing them is unsafe:

```rust
static mut COUNTER: u32 = 0;

fn add_to_count(inc: u32) {
    unsafe {
        COUNTER += inc;
    }
}

fn main() {
    add_to_count(3);
    
    unsafe {
        println!("COUNTER: {}", COUNTER);
    }
}
```

**Why is this unsafe?** Multiple threads could access COUNTER simultaneously, causing data races.

### 16.7 Implementing Unsafe Traits

A trait is unsafe when at least one of its methods has invariants the compiler can't verify:

```rust
unsafe trait Foo {
    // Methods
}

unsafe impl Foo for i32 {
    // Implementation
}
```

Example: `Send` and `Sync` are unsafe traits.

### 16.8 Unions

Unions are like structs but only one field is active at a time:

```rust
#[repr(C)]
union MyUnion {
    f1: u32,
    f2: f32,
}

fn main() {
    let u = MyUnion { f1: 1 };
    
    unsafe {
        println!("u.f1: {}", u.f1);
        // println!("u.f2: {}", u.f2); // Undefined behavior!
    }
}
```

### 16.9 Practical Example: Implementing a Vec-like Structure

Let's implement a simplified vector using unsafe code:

```rust
use std::alloc::{alloc, dealloc, Layout};
use std::ptr;

struct MyVec<T> {
    ptr: *mut T,
    len: usize,
    capacity: usize,
}

impl<T> MyVec<T> {
    fn new() -> Self {
        MyVec {
            ptr: std::ptr::null_mut(),
            len: 0,
            capacity: 0,
        }
    }
    
    fn push(&mut self, value: T) {
        if self.len == self.capacity {
            self.grow();
        }
        
        unsafe {
            ptr::write(self.ptr.add(self.len), value);
        }
        
        self.len += 1;
    }
    
    fn pop(&mut self) -> Option<T> {
        if self.len == 0 {
            None
        } else {
            self.len -= 1;
            unsafe {
                Some(ptr::read(self.ptr.add(self.len)))
            }
        }
    }
    
    fn grow(&mut self) {
        let new_capacity = if self.capacity == 0 {
            1
        } else {
            self.capacity * 2
        };
        
        let new_layout = Layout::array::<T>(new_capacity).unwrap();
        
        let new_ptr = if self.capacity == 0 {
            unsafe { alloc(new_layout) as *mut T }
        } else {
            let old_layout = Layout::array::<T>(self.capacity).unwrap();
            let old_ptr = self.ptr as *mut u8;
            unsafe {
                let new_ptr = alloc(new_layout);
                ptr::copy_nonoverlapping(old_ptr, new_ptr, old_layout.size());
                dealloc(old_ptr, old_layout);
                new_ptr as *mut T
            }
        };
        
        self.ptr = new_ptr;
        self.capacity = new_capacity;
    }
}

impl<T> Drop for MyVec<T> {
    fn drop(&mut self) {
        if self.capacity != 0 {
            while self.pop().is_some() {}
            
            let layout = Layout::array::<T>(self.capacity).unwrap();
            unsafe {
                dealloc(self.ptr as *mut u8, layout);
            }
        }
    }
}

fn main() {
    let mut vec = MyVec::new();
    vec.push(1);
    vec.push(2);
    vec.push(3);
    
    while let Some(value) = vec.pop() {
        println!("{}", value);
    }
}
```

**Safety Invariants**:
- `ptr` points to valid memory or is null
- `len <= capacity`
- Elements from 0 to len-1 are initialized
- Memory is properly aligned

### 16.10 Exercises: Unsafe Rust

**Exercise 1**: Implement a function that safely wraps `memcpy` from C.

**Exercise 2**: Create a safe wrapper around a raw pointer that ensures it's never null.

**Exercise 3**: Implement a simple arena allocator using unsafe code.

---

## 17. Foreign Function Interface (FFI)

### 17.1 Calling C from Rust

Use `extern` blocks to declare C functions:

```rust
extern "C" {
    fn abs(input: i32) -> i32;
    fn sqrt(input: f64) -> f64;
}

fn main() {
    unsafe {
        println!("abs(-5) = {}", abs(-5));
        println!("sqrt(9.0) = {}", sqrt(9.0));
    }
}
```

### 17.2 Calling Rust from C

Make Rust functions callable from C:

```rust
#[no_mangle]
pub extern "C" fn rust_function(x: i32) -> i32 {
    x * 2
}
```

The `#[no_mangle]` attribute prevents name mangling, making the function callable from C.

### 17.3 Representing C Types

Use types from `std::os::raw`:

```rust
use std::os::raw::{c_int, c_char, c_void};

extern "C" {
    fn strlen(s: *const c_char) -> c_int;
    fn malloc(size: usize) -> *mut c_void;
    fn free(ptr: *mut c_void);
}
```

### 17.4 Working with C Strings

Convert between Rust and C strings:

```rust
use std::ffi::{CString, CStr};
use std::os::raw::c_char;

extern "C" {
    fn puts(s: *const c_char) -> i32;
}

fn main() {
    let rust_string = "Hello from Rust!";
    let c_string = CString::new(rust_string).unwrap();
    
    unsafe {
        puts(c_string.as_ptr());
    }
}
```

### 17.5 Callbacks from C to Rust

Pass Rust functions as callbacks to C:

```rust
extern "C" fn callback(value: i32) {
    println!("Callback called with: {}", value);
}

extern "C" {
    fn register_callback(cb: extern "C" fn(i32));
    fn trigger_callback();
}

fn main() {
    unsafe {
        register_callback(callback);
        trigger_callback();
    }
}
```

### 17.6 Using bindgen

Automatically generate Rust FFI bindings:

```toml
[build-dependencies]
bindgen = "0.69"
```

Build script:

```rust
// build.rs
extern crate bindgen;

use std::env;
use std::path::PathBuf;

fn main() {
    println!("cargo:rustc-link-lib=mylib");
    
    let bindings = bindgen::Builder::default()
        .header("wrapper.h")
        .parse_callbacks(Box::new(bindgen::CargoCallbacks))
        .generate()
        .expect("Unable to generate bindings");
    
    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
    bindings
        .write_to_file(out_path.join("bindings.rs"))
        .expect("Couldn't write bindings!");
}
```

### 17.7 Practical Example: Wrapping a C Library

Let's wrap a simple C library:

```c
// mylib.h
typedef struct {
    int x;
    int y;
} Point;

Point* point_new(int x, int y);
void point_free(Point* p);
int point_distance(Point* p1, Point* p2);
```

Rust wrapper:

```rust
use std::os::raw::c_int;

#[repr(C)]
struct Point {
    x: c_int,
    y: c_int,
}

extern "C" {
    fn point_new(x: c_int, y: c_int) -> *mut Point;
    fn point_free(p: *mut Point);
    fn point_distance(p1: *const Point, p2: *const Point) -> c_int;
}

pub struct SafePoint {
    ptr: *mut Point,
}

impl SafePoint {
    pub fn new(x: i32, y: i32) -> Self {
        unsafe {
            SafePoint {
                ptr: point_new(x, y),
            }
        }
    }
    
    pub fn distance(&self, other: &SafePoint) -> i32 {
        unsafe {
            point_distance(self.ptr, other.ptr)
        }
    }
}

impl Drop for SafePoint {
    fn drop(&mut self) {
        unsafe {
            point_free(self.ptr);
        }
    }
}

fn main() {
    let p1 = SafePoint::new(0, 0);
    let p2 = SafePoint::new(3, 4);
    
    println!("Distance: {}", p1.distance(&p2));
}
```

### 17.8 Exercises: FFI

**Exercise 1**: Create Rust bindings for a C math library.

**Exercise 2**: Implement a safe wrapper around C's `FILE*` operations.

**Exercise 3**: Write a Rust library that can be called from C, including proper error handling.

---

## 18. Advanced Lifetime Patterns

### 18.1 Lifetime Subtyping

Lifetimes have a subtyping relationship:

```rust
fn longest<'a, 'b: 'a>(x: &'a str, y: &'b str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

The `'b: 'a` syntax means "'b outlives 'a" or "'b is a subtype of 'a".

### 18.2 Lifetime Bounds on Types

Types can have lifetime bounds:

```rust
struct Ref<'a, T: 'a> {
    reference: &'a T,
}
```

In Rust 2018+, this is often implicit, but understanding it is important.

### 18.3 Higher-Ranked Trait Bounds (HRTBs)

Express constraints over all possible lifetimes:

```rust
fn call_with_one<F>(f: F) -> usize
where
    F: for<'a> Fn(&'a i32) -> usize,
{
    let value = 1;
    f(&value)
}

fn main() {
    let result = call_with_one(|x| *x as usize);
    println!("{}", result);
}
```

### 18.4 Lifetime Elision in Impl Blocks

Lifetime elision rules apply to impl blocks:

```rust
struct StrWrap<'a>(&'a str);

impl<'a> StrWrap<'a> {
    fn inner(&self) -> &str {
        self.0
    }
}
```

The return type's lifetime is inferred to be `'a`.

### 18.5 Multiple Lifetimes in Structs

Structs can have multiple lifetime parameters:

```rust
struct Context<'a, 'b> {
    first: &'a str,
    second: &'b str,
}

impl<'a, 'b> Context<'a, 'b> {
    fn get_first(&self) -> &'a str {
        self.first
    }
    
    fn get_second(&self) -> &'b str {
        self.second
    }
}
```

### 18.6 Practical Example: Self-Referential Structs

Self-referential structs are tricky in Rust. Here's a safe approach using `Pin`:

```rust
use std::pin::Pin;

struct SelfReferential {
    data: String,
    pointer: *const String,
}

impl SelfReferential {
    fn new(data: String) -> Pin<Box<Self>> {
        let mut boxed = Box::pin(SelfReferential {
            data,
            pointer: std::ptr::null(),
        });
        
        let ptr = &boxed.data as *const String;
        unsafe {
            let mut_ref = Pin::as_mut(&mut boxed);
            Pin::get_unchecked_mut(mut_ref).pointer = ptr;
        }
        
        boxed
    }
    
    fn get_data(&self) -> &str {
        &self.data
    }
    
    fn get_pointer_data(&self) -> &str {
        unsafe { &*self.pointer }
    }
}

fn main() {
    let sr = SelfReferential::new(String::from("Hello"));
    println!("Data: {}", sr.get_data());
    println!("Pointer data: {}", sr.get_pointer_data());
}
```

### 18.7 Exercises: Advanced Lifetimes

**Exercise 1**: Implement a struct that holds references with different lifetimes and methods that return each reference.

**Exercise 2**: Create a function that takes a closure with HRTB constraints.

**Exercise 3**: Design a safe API for a self-referential data structure.

---

## 19. Variance and Subtyping

### 19.1 Understanding Variance

Variance describes how subtyping relationships between types relate to subtyping relationships between their components.

**Covariance**: If `'a: 'b`, then `&'a T` is a subtype of `&'b T`

```rust
fn covariant<'a>(x: &'a str) -> &'static str {
    // This works because &'static str is a subtype of &'a str
    "hello"
}
```

**Contravariance**: If `'a: 'b`, then `fn(&'b T)` is a subtype of `fn(&'a T)`

**Invariance**: No subtyping relationship

### 19.2 Variance in Practice

```rust
// &'a T is covariant in 'a and T
fn covariant_example<'a, 'b: 'a>(x: &'b i32) -> &'a i32 {
    x // OK: &'b i32 is a subtype of &'a i32
}

// &'a mut T is covariant in 'a but invariant in T
fn invariant_example<'a>(x: &'a mut i32) -> &'a mut i32 {
    x
}
```

### 19.3 PhantomData and Variance

Control variance with `PhantomData`:

```rust
use std::marker::PhantomData;

struct Invariant<'a, T> {
    data: *mut T,
    _marker: PhantomData<&'a mut T>,
}
```

### 19.4 Exercises: Variance

**Exercise 1**: Explain why `&mut T` is invariant in `T`.

**Exercise 2**: Implement a type that is contravariant in its type parameter.

**Exercise 3**: Use `PhantomData` to control the variance of a custom type.

---

## 20. Zero-Cost Abstractions

### 20.1 What Are Zero-Cost Abstractions?

Zero-cost abstractions mean you don't pay a runtime penalty for using high-level abstractions. The compiled code is as efficient as hand-written low-level code.

### 20.2 Iterator Example

High-level iterator code:

```rust
fn sum_of_squares(numbers: &[i32]) -> i32 {
    numbers.iter()
        .map(|&x| x * x)
        .sum()
}
```

Compiles to the same assembly as:

```rust
fn sum_of_squares_manual(numbers: &[i32]) -> i32 {
    let mut sum = 0;
    for &x in numbers {
        sum += x * x;
    }
    sum
}
```

### 20.3 Monomorphization

Generics are zero-cost through monomorphization:

```rust
fn print<T: std::fmt::Display>(value: T) {
    println!("{}", value);
}

fn main() {
    print(5);
    print("hello");
}
```

The compiler generates two specialized versions:

```rust
fn print_i32(value: i32) {
    println!("{}", value);
}

fn print_str(value: &str) {
    println!("{}", value);
}
```

### 20.4 Inline Assembly

For ultimate control, use inline assembly:

```rust
use std::arch::asm;

fn add_one(x: u32) -> u32 {
    let result: u32;
    unsafe {
        asm!(
            "add {0}, 1",
            inout(reg) x => result,
        );
    }
    result
}
```

### 20.5 Exercises: Zero-Cost Abstractions

**Exercise 1**: Compare the assembly output of iterator-based and loop-based code.

**Exercise 2**: Implement a zero-cost abstraction for a state machine.

**Exercise 3**: Use inline assembly to optimize a critical function.

---

## 21. Compiler Internals and MIR

### 21.1 Compilation Stages

Rust compilation goes through several stages:

1. **Parsing**: Source code → AST (Abstract Syntax Tree)
2. **HIR**: AST → HIR (High-level Intermediate Representation)
3. **Type Checking**: HIR with type information
4. **MIR**: HIR → MIR (Mid-level Intermediate Representation)
5. **Optimization**: MIR optimizations
6. **Codegen**: MIR → LLVM IR → Machine code

### 21.2 Viewing MIR

View MIR for your code:

```bash
rustc --emit=mir main.rs
```

Or use:

```bash
cargo rustc -- --emit=mir
```

### 21.3 MIR Example

For this code:

```rust
fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

MIR looks like:

```
fn add(_1: i32, _2: i32) -> i32 {
    let mut _0: i32;
    
    bb0: {
        _0 = Add(move _1, move _2);
        return;
    }
}
```

### 21.4 Exercises: Compiler Internals

**Exercise 1**: View and analyze the MIR for a complex function.

**Exercise 2**: Compare MIR output for debug and release builds.

**Exercise 3**: Identify optimization opportunities in MIR.

---

## 22. Advanced Async Programming

### 22.1 Custom Futures

Implement the `Future` trait manually:

```rust
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};

struct CounterFuture {
    count: u32,
    max: u32,
}

impl Future for CounterFuture {
    type Output = u32;
    
    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        self.count += 1;
        
        if self.count >= self.max {
            Poll::Ready(self.count)
        } else {
            cx.waker().wake_by_ref();
            Poll::Pending
        }
    }
}
```

### 22.2 Custom Executors

Build a simple executor:

```rust
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll, RawWaker, RawWakerVTable, Waker};

fn dummy_waker() -> Waker {
    fn no_op(_: *const ()) {}
    fn clone(_: *const ()) -> RawWaker {
        dummy_raw_waker()
    }
    
    fn dummy_raw_waker() -> RawWaker {
        RawWaker::new(
            std::ptr::null(),
            &RawWakerVTable::new(clone, no_op, no_op, no_op),
        )
    }
    
    unsafe { Waker::from_raw(dummy_raw_waker()) }
}

fn block_on<F: Future>(mut future: F) -> F::Output {
    let mut future = unsafe { Pin::new_unchecked(&mut future) };
    let waker = dummy_waker();
    let mut context = Context::from_waker(&waker);
    
    loop {
        match future.as_mut().poll(&mut context) {
            Poll::Ready(value) => return value,
            Poll::Pending => {},
        }
    }
}
```

### 22.3 Async Streams

Work with async streams:

```rust
use futures::stream::{self, StreamExt};

async fn process_stream() {
    let mut stream = stream::iter(vec![1, 2, 3, 4, 5]);
    
    while let Some(value) = stream.next().await {
        println!("Got: {}", value);
    }
}
```

### 22.4 Exercises: Advanced Async

**Exercise 1**: Implement a custom future that reads from a file asynchronously.

**Exercise 2**: Build a simple async runtime with task scheduling.

**Exercise 3**: Create an async stream that generates Fibonacci numbers.

---

## 23. Embedded Systems Programming

### 23.1 No-Std Environment

Embedded Rust often runs without the standard library:

```rust
#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    loop {}
}
```

### 23.2 Hardware Abstraction

Use HAL crates for hardware access:

```rust
#![no_std]
#![no_main]

use cortex_m_rt::entry;
use stm32f4xx_hal::{pac, prelude::*};

#[entry]
fn main() -> ! {
    let dp = pac::Peripherals::take().unwrap();
    let gpioa = dp.GPIOA.split();
    
    let mut led = gpioa.pa5.into_push_pull_output();
    
    loop {
        led.set_high();
        cortex_m::asm::delay(1_000_000);
        led.set_low();
        cortex_m::asm::delay(1_000_000);
    }
}
```

### 23.3 Embedded Async

Use `embassy` for async embedded:

```rust
#![no_std]
#![no_main]

use embassy_executor::Spawner;
use embassy_time::{Duration, Timer};

#[embassy_executor::main]
async fn main(_spawner: Spawner) {
    loop {
        // Toggle LED
        Timer::after(Duration::from_millis(1000)).await;
    }
}
```

### 23.4 Exercises: Embedded

**Exercise 1**: Write a no-std program that blinks an LED.

**Exercise 2**: Implement UART communication in embedded Rust.

**Exercise 3**: Create an async embedded application with multiple tasks.

---

*[Content continues with Part IV: Practical Applications...]*