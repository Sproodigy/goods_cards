module Cappuccinator
  def create_foam
    prepare_milk
    push_foam
  end

  private

  def prepare_milk
    puts "Отбираем и кипятим молоко"
  end

  def push_foam
    puts "Выпускаем молочную пенку в чашку"
  end
end

module LatteArt
  private

  def push_foam
    puts "Красивыми узорами выкладываем пену в чашку."
  end
end

class CoffeeMachine

  attr_accessor :cups_count

  def initialize(count = 1)
    @cups_count = count
  end

  def make_coffee
    get_water(200)  # набираем воду
    get_beans(50)   # набираем зёрна
    prepare_beans   # готовим зёрна
    boil_water      # кипятим воду
    pour_coffee     # наливаем кофе в чашку
  end

  protected

  def get_water(mls)
    puts "Набираем в ёмкость #{mls} мл воды."
  end

  def get_beans(grams)
    puts "Отбираем из контейнера #{grams} г зёрен кофе."
  end

  def prepare_beans
    puts 'Готовим зёрна.'
  end

  def boil_water
    puts 'Кипятим воду.'
  end

  def pour_coffee
    puts 'Наливаем кофе в чашку.'
  end
end

class Cleaner
  def clean(machine)
   machine.get_water(200)
   machine.boil_water
   machine.pour_coffee
  end
end

class MachineCleaner < CoffeeMachine
  def clean(machine)
    machine.get_water(200)
    machine.boil_water
    machine.pour_coffee
  end
end

class CappuccinoMachine < CoffeeMachine
  include Cappuccinator
end

class CapsuleMachine < CoffeeMachine
  def make_coffee
    get_water(200)
    prepare_capsule
    boil_water
    pour_coffee
  end

  private

  def prepare_capsule
    puts "Вскрываем капсулу и высыпаем кофе в ёмкость."
  end
end

class CapsuleCappuccino < CoffeeMachine
  include Cappuccinator
  include LatteArt
end

class HappyCounter
  attr_reader :count # удобный способ создать геттер

  # сеттер
  def count=(value)
    @count = value
    play_melody if premium_count?
  end

  def initialize
    @count = 0
  end

  def premium_count?
    @count % 1000 == 0 # проверяем остаток от деления
  end

  private

  def play_melody
    puts "Та-дааам!!!"
  end
end


saeco = CoffeeMachine.new
puts self
saeco.make_coffee

cleaner = Cleaner.new
machine_cleaner = MachineCleaner.new
machine_cleaner.clean(saeco)
cleaner.clean(saeco)
