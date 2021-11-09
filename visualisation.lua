package.path = package.path..";A:/crystals_rbw/?.lua"
require "model"

--создать поле
function GameField:new(N, M)
  self.N = N
  self.M = M
  local newObj = {field = {}}
  self.isInit = true
  self.destroyed = 0
  self.__index = self
  return setmetatable(newObj, self)
end

--создать кристалл
function Crystal:new(user_chosen_colour, user_chosen_moved)
  if user_chosen_moved ~= nil then
    m = user_chosen_moved
  else
    m = true
  end
  local newObj = {
    --можно задать цвет специально, иначе случайно выберется один из возможных вариантов
    colour = user_chosen_colour and user_chosen_colour or numberToColour(math.random(6)),
    --можно специально указать, что кристалл был перемещён, иначе он не стоял на месте
    moved = m,
    marked = false
  }
  self.__index = self
  return setmetatable(newObj, self)
end

--преобразовать случайное число в цвет
function numberToColour(number)
  if number == 1 then
    return "A"
  elseif number == 2 then
    return "B"
  elseif number == 3 then
    return "C"
  elseif number == 4 then
    return "D"
  elseif number == 5 then
    return "E"
  else
    return "F"
  end
end

--выход
function quit()
  print("Wrong input")
  os.exit()
end

--откуда куда двигаемся
function checkInput()
  d = string.gsub(d, "%s+", "")
  local from = {x = x, y = y}
  local to = {}
  if d == "l" then
    to.x = x
    to.y = y - 1
  elseif d == "r" then
    to.x = x
    to.y = y + 1
  elseif d == "u" then
    to.x = x - 1
    to.y = y
  elseif d == "d" then
    to.x = x + 1
    to.y = y
  else
    print('Wrong input')
    return false
  end
  gameField:move(from, to)
  return true
end

--проверить поле
function GameField:checkField()
  for i = 1, self.N do
    for j = 1, self.M do
      --есть перемещённый кристалл?
      if self.field[i][j].moved then
        --проверим комбинации для него
        self:checkForOne(i, j)                
      end
    end
  end

  if not self.isInit then
    --пустого пространства быть не должно
    self:fall()
  end
end

--проверить одноцветные по строке и по столбцу для перемещённого элемента
function GameField:checkForOne(i, j)
  --для следующего хода этот элемент уже не обязательно будет перемещённым
  self.field[i][j].moved = false
  --специальный камень?
  for key, value in pairs(specialStones) do
    if self.field[i][j].colour == key then
      --особый эффект
      value()
      return
    end
  end
  --одноцветные в столбце
  local column_marked = 0
  --одноцветные в строке
  local row_marked = 0
  --одноцветные сверху
  for k = i - 1, 1, -1 do
    if i <= 1 or self.field[i][j].colour ~= self.field[k][j].colour then
      break
    end
  self.field[k][j].marked = true
  column_marked = column_marked + 1
  end

  --одноцветные снизу
  for k = i + 1, self.N do
    if i + 1 > self.N or self.field[i][j].colour ~= self.field[k][j].colour then
      break
    end
    self.field[k][j].marked = true
    column_marked = column_marked + 1
  end

  --одноцветные слева
  for l = j - 1, 1, -1 do
    if j <= 1 or self.field[i][j].colour ~= self.field[i][l].colour then
      break
    end
    self.field[i][l].marked = true
    row_marked = row_marked + 1
  end

  --одноцветные справа
  for l = j + 1, self.M do
    if j + 1 > self.M or self.field[i][j].colour ~= self.field[i][l].colour then
      break
    end
    self.field[i][l].marked = true
    row_marked = row_marked + 1
  end

  --в строке достаточно одноцветных?
  if row_marked >= 2 then
    row_marked = row_marked + 1
  else
    for j = 1, self.M do
    --слишком мало одноцветных, не трогаем их
    self.field[i][j].marked = false
    end
  end

  --в столбце достаточно одноцветных?
  if column_marked >= 2 then      
    column_marked = column_marked + 1
  else
    for i = 1, self.N do
    --слишком мало одноцветных, не трогаем их
    self.field[i][j].marked = false
    end
  end

  --есть комбинации?
  if row_marked >=3 or column_marked >= 3 then
    --сам элемент тоже часть комбинации
    self.field[i][j].marked = true
    for i = 1, self.N do
      for j = 1, self.M do
        if self.field[i][j].marked then
          --удаляем кристалл
          self.field[i][j].colour = " "
          --проверяем нагенеренное поле?
          if self.isInit then
            --заменяем кристалл
            self.field[i][j] = Crystal:new()
            --проверяем, что комбинации больше нет
            self:checkForOne(i, j)
            self:fall(i, j)
          else
            self.destroyed = self.destroyed + 1
          end
        end
      end
    end
  end
end

--смещение кристаллов на освободившиеся места
function GameField:fall(row, column)
  start = {x = self.N, y = 1}
  --можно задать точку начала просмотра наличия пустоты
  if row ~= nil and column ~= nil then
    start.x, start.y = self.N, 1
  end
  for i = start.x, 1, -1 do
    for j = start.y, self.M do
      --кристалла нет?
      if self.field[i][j].colour == " " then
        --посмотрим на пространство над пустотой
        for k = i, 1, -1 do
          --наверху нет кристалла?
          if k == 1 and self.field[k][j].colour == " " then
            --надо это исправить
            self.field[k][j] = Crystal:new()
          end
          --нашли кристалл?
          if self.field[k][j].colour ~= " " then
            --пусть он займёт пустое место
            self.field[i][j], self.field[k][j] = self.field[k][j], self.field[i][j]
            self.field[i][j].moved = true
            --не появилась ли комбинация?
            self:checkForOne(i, j)
            self:fall(i, j)
            --идём дальше
            break
          end                    
        end
      end
    end
  end
end

--проверяем необходимость перемешивания
function checkAndMixIfNeeded()
  while not combinationsExist() do
    --мешаем до появления возможности сходить
    gameField:mix()
  end
end

--пробуем сходить каждым кристаллом в каждую сторону
function combinationsExist()
  moving = true
  local check = gameField.destroyed
  local field = copy(gameField.field)
  for i = 1, gameField.N do
    x = i
    for j = 1, gameField.M do
      y = j
      local directions = {"l", "u", "r", "d"}
      for k = 1, 4 do
        d = directions[k]            
        checkInput()
        --комбинации есть?
        if check ~= gameField.destroyed then
          moving = false
          gameField.destroyed = check
          gameField.field = field
          return true
        end
      end
    end
  end
  moving = false
  gameField.destroyed = check
  gameField.field = field
  return false
end

--копирование по значению
function copy(obj, seen)
  if type(obj) ~= "table" then
    return obj
  end
  if seen and seen[obj] then
    return seen[obj]
  end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do
    res[copy(k, s)] = copy(v, s)
  end
  return res
end

--блок особых камней и функций, которые они вызывают
specialStones = {
  ["m"] = hello,
  ["o"] = there,
  ["b"] = man
}

function hello()
  print("Hello")
end

function there()
  print("there")
end

function man()
  print("man")
end

gameField = GameField:new(10, 10)
gameField:init()
tick()