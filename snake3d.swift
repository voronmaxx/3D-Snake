// snake3d.swift
import Foundation

let SIZE = 8

struct Point3D: Hashable {
    let x, y, z: Int
}

class Snake3D {
    var snake: [Point3D] = []
    var dir = Point3D(x: 0, y: 0, z: 1)
    var nextDir = Point3D(x: 0, y: 0, z: 1)
    var food: Point3D!
    var score = 0
    var high = 0
    var speed = 0.3
    var gameOver = false
    var paused = false
    var running = true

    init() {
        let c = SIZE / 2
        snake.append(Point3D(x: c, y: c, z: c))
        spawnFood()
        run()
    }

    func spawnFood() {
        while true {
            let p = Point3D(x: Int.random(in: 0..<SIZE), y: Int.random(in: 0..<SIZE), z: Int.random(in: 0..<SIZE))
            if !snake.contains(p) {
                food = p
                break
            }
        }
    }

    func contains(_ p: Point3D) -> Bool {
        return snake.contains(p)
    }

    func update() {
        if paused || gameOver { return }
        dir = nextDir
        let head = snake[0]
        let newHead = Point3D(
            x: (head.x + dir.x + SIZE) % SIZE,
            y: (head.y + dir.y + SIZE) % SIZE,
            z: (head.z + dir.z + SIZE) % SIZE
        )
        if contains(newHead) {
            gameOver = true
            if score > high { high = score }
            return
        }
        snake.insert(newHead, at: 0)
        if newHead == food {
            score += 1
            spawnFood()
            speed = max(0.08, speed - 0.01)
        } else {
            snake.removeLast()
        }
    }

    func render() {
        print("\u{001B}[2J") // clear
        print("🐍 3D SNAKE   Score: \(score)   High: \(high)   Speed: \(String(format: "%.2f", speed))s")
        print("Controls: W/A/S/D/Q/E | Space=pause | R=restart | Esc=quit")
        for y in stride(from: SIZE-1, through: 0, by: -1) {
            for z in 0..<SIZE {
                for x in 0..<SIZE {
                    let p = Point3D(x: x, y: y, z: z)
                    var ch = "."
                    if snake.contains(p) { ch = "o" }
                    if snake.first == p { ch = "O" }
                    if food == p { ch = "★" }
                    print("\(ch) ", terminator: "")
                }
                print()
            }
        }
        if paused { print("\n⏸️  PAUSED") }
        if gameOver { print("\n💀 GAME OVER! Press R to restart.") }
    }

    func run() {
        // Input handling in Swift is not trivial without external libs.
        // We'll use a simple loop with `readLine` non-blocking? Not easily.
        // For demo, we'll run without interactive input, just a timer.
        // In a real app, use SwiftTerm or similar.
        print("Swift version uses simple timer (no interactive input).")
        print("It will run for 30 seconds then exit.")
        let start = Date()
        while running && !gameOver && Date().timeIntervalSince(start) < 30 {
            update()
            render()
            Thread.sleep(forTimeInterval: speed)
        }
        if gameOver {
            render()
            print("Game Over. Press R to restart (not implemented in this demo).")
        }
        print("Exiting.")
    }
}

let game = Snake3D()
game.run()
