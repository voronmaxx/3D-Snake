// Snake3D.cs
using System;
using System.Collections.Generic;
using System.Threading;

class Snake3D
{
    const int SIZE = 8;
    List<(int x, int y, int z)> snake = new List<(int, int, int)>();
    (int x, int y, int z) dir = (0, 0, 1);
    (int x, int y, int z) nextDir = (0, 0, 1);
    (int x, int y, int z) food;
    int score = 0, high = 0;
    int speed = 300; // ms
    bool gameOver = false, paused = false, running = true;
    Random rand = new Random();

    public Snake3D()
    {
        int c = SIZE / 2;
        snake.Add((c, c, c));
        SpawnFood();
        // Input thread
        Thread inputThread = new Thread(InputLoop);
        inputThread.IsBackground = true;
        inputThread.Start();
        Run();
    }

    void SpawnFood()
    {
        while (true)
        {
            var pos = (rand.Next(SIZE), rand.Next(SIZE), rand.Next(SIZE));
            if (!snake.Contains(pos))
            {
                food = pos;
                break;
            }
        }
    }

    bool Contains((int x, int y, int z) pos)
    {
        return snake.Contains(pos);
    }

    void Update()
    {
        if (paused || gameOver) return;
        dir = nextDir;
        var head = snake[0];
        var newHead = (
            (head.x + dir.x + SIZE) % SIZE,
            (head.y + dir.y + SIZE) % SIZE,
            (head.z + dir.z + SIZE) % SIZE
        );
        if (Contains(newHead))
        {
            gameOver = true;
            if (score > high) high = score;
            return;
        }
        snake.Insert(0, newHead);
        if (newHead == food)
        {
            score++;
            SpawnFood();
            speed = Math.Max(80, speed - 10);
        }
        else
        {
            snake.RemoveAt(snake.Count - 1);
        }
    }

    void Render()
    {
        Console.Clear();
        Console.WriteLine($"🐍 3D SNAKE   Score: {score}   High: {high}   Speed: {(speed/1000.0):F2}s");
        Console.WriteLine("Controls: W/A/S/D/Q/E | Space=pause | R=restart | Esc=quit");
        for (int y = SIZE - 1; y >= 0; y--)
        {
            for (int z = 0; z < SIZE; z++)
            {
                for (int x = 0; x < SIZE; x++)
                {
                    var pos = (x, y, z);
                    char ch = '.';
                    if (snake.Contains(pos)) ch = 'o';
                    if (snake[0] == pos) ch = 'O';
                    if (food == pos) ch = '★';
                    Console.Write($"{ch} ");
                }
                Console.WriteLine();
            }
        }
        if (paused) Console.WriteLine("\n⏸️  PAUSED");
        if (gameOver) Console.WriteLine("\n💀 GAME OVER! Press R to restart.");
    }

    void InputLoop()
    {
        while (running)
        {
            var key = Console.ReadKey(true);
            switch (key.Key)
            {
                case ConsoleKey.Spacebar:
                    paused = !paused;
                    break;
                case ConsoleKey.R:
                    if (gameOver)
                    {
                        int c = SIZE / 2;
                        snake.Clear();
                        snake.Add((c, c, c));
                        dir = (0, 0, 1);
                        nextDir = (0, 0, 1);
                        score = 0;
                        speed = 300;
                        gameOver = false;
                        SpawnFood();
                    }
                    break;
                case ConsoleKey.W: nextDir = (0, 0, 1); break;
                case ConsoleKey.S: nextDir = (0, 0, -1); break;
                case ConsoleKey.A: nextDir = (-1, 0, 0); break;
                case ConsoleKey.D: nextDir = (1, 0, 0); break;
                case ConsoleKey.Q: nextDir = (0, 1, 0); break;
                case ConsoleKey.E: nextDir = (0, -1, 0); break;
                case ConsoleKey.UpArrow: nextDir = (0, 0, 1); break;
                case ConsoleKey.DownArrow: nextDir = (0, 0, -1); break;
                case ConsoleKey.LeftArrow: nextDir = (-1, 0, 0); break;
                case ConsoleKey.RightArrow: nextDir = (1, 0, 0); break;
                case ConsoleKey.Escape:
                    running = false;
                    return;
            }
        }
    }

    void Run()
    {
        while (running && !gameOver)
        {
            Update();
            Render();
            Thread.Sleep(speed);
        }
        if (gameOver)
        {
            Render();
            while (running)
            {
                var key = Console.ReadKey(true);
                if (key.Key == ConsoleKey.R)
                {
                    int c = SIZE / 2;
                    snake.Clear();
                    snake.Add((c, c, c));
                    dir = (0, 0, 1);
                    nextDir = (0, 0, 1);
                    score = 0;
                    speed = 300;
                    gameOver = false;
                    SpawnFood();
                    Run();
                    return;
                }
                if (key.Key == ConsoleKey.Escape) break;
            }
        }
    }

    static void Main()
    {
        new Snake3D();
    }
}
