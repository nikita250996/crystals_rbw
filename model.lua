  --класс игровое поле
  GameField = {}
  --класс кристалл
  Crystal = {}
  math.randomseed(os.time())

  --init
  --заполнить поле
  function GameField:init()
    for i = 1, self.N do
      self.field[i] = {}
      for j = 1, self.M do
        self.field[i][j] = Crystal:new()
      end
    end
    --если сразу есть три или больше в ряд, надо от них избавиться, но очки за это не давать
    self:checkField()
    self.isInit = false
    checkAndMixIfNeeded()
  end

  --tick
  function tick()
    local changed = true
    --пока есть изменения
    while changed do
      --пока игрок не сделал ход
      moved = false
      while not moved do            
        --вывести поле
        gameField:dump()
        --запросить ввод
        print("\nPlease, type q if you want to quit. Otherwise, first type m, then row (0-9), column (0-9), move direction (l for left, r for right, u for up, d for down)")
        local type = io.read(1)
        --выходим или играем?
        if type == "q" then
          os.exit()
        elseif type ~= "m" then
          quit()
        end
        --какой кристалл куда двигаем
        x, y, d = io.read("*number", "*number", "*line")
        --нумерация строк и столбцов при выводе идёт с нуля для красоты, но в коде она обычная
        x = x + 1
        y = y + 1
        --пробуем сделать ход
        changed = checkInput()
      end            
      checkAndMixIfNeeded()
    end
  end

  --dump
  --нарисовать поле
  function GameField:dump()
    io.write("\n     ")
    for i = 1, self.M do
      io.write(i - 1 .. " ")
    end
    print()
    io.write("   ")
    for i = 1, self.M + 1 do
      io.write("_ ")
    end
    print("Total crystals destroyed " .. self.destroyed)
    for i = 1, self.N do
      length = string.len(tostring(i - 1))
      for j = 1, self.M do
        if j == 1 then
          io.write(i - 1 .. " " .. "|")                
          if length == 1 then
            io.write("  ")
          else
            io.write(" ")
          end
        end
        io.write(self.field[i][j].colour .. " ")
      end
      print()
    end
  end

  --move
  --делаем ход
  function GameField:move(from, to)
    --обращаемся к кристаллу за пределами поля?
    if from.x > self.N or from.x < 1 or from.y > self.M or from.y < 1 then
      print("There are no crystals outside the field")
      return
    end
    --можем сходить?
    if to.x <= self.N and to.x >= 1 and to.y <= self.M and to.y >= 1 then
      self.field[to.x][to.y], self.field[from.x][from.y] = self.field[from.x][from.y], self.field[to.x][to.y]
      self.field[to.x][to.y].moved = true
      self.field[from.x][from.y].moved = true
      local check = self.destroyed
      gameField:checkField()
      --после перемещения кристалла не было комбинаций?
      if check == self.destroyed then
      --возвращаем кристаллы на исходные позиции
      self.field[to.x][to.y], self.field[from.x][from.y] = self.field[from.x][from.y], self.field[to.x][to.y]
      end
      moved = true
    elseif not moving then
      print("You can't move there")
    end
  end

  --mix
  function GameField:mix()
    for i = 1, self.N do
      for j = 1, self.M do
        --пробуем заменить кристалл другим, чтобы комбинации появились
        self.field[i][j] = Crystal:new()
        self.isInit = true
        self:checkField()
        self.isInit = false
        --комбинации появились?
        if combinationsExist() then
          --отлично
          return
        end
      end
    end
  end