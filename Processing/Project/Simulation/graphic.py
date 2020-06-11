import matplotlib.pyplot as plt

PATH = input("Имя графика: ")
if PATH:
    PATH = "logs/" + PATH
else:
    PATH = "logs/log5"

with open(f"{PATH}.csv") as f:
    text = f.readlines()[1:]

array = []

for i in text:
    array.append(list(map(float, i.split(','))))
    


array = tuple(zip(*array))

plt.title("График зависимости кол-ва частиц от модуля скорости")
plt.xlabel("Скорость")
plt.ylabel("Кол-во ")
plt.grid()

plt.figure(figsize=(12, 12))

plt.subplot(2, 1, 2)
plt.fill_between(array[1], array[2], color='red', label='Распределение скоростей', alpha=0.6)
plt.title("График кол-ва частиц от модуля скорости")
plt.xlabel("Скорость")
plt.ylabel("Количество частиц")
plt.grid()
plt.legend()


plt.savefig(f'{PATH}.png')
