# array of x
NizX = [1, 1, 5, 5]
NizY = [1, 3, 5, 2]

MaxNiz = len(NizX)
mstSet = [0] * len(NizX)
mstSetCount = 0
cvorU = 99999
NizKljuceva = [9999] * len(NizX)

# print(mstSet)

NizKljuceva[0] = 0
while (mstSetCount < MaxNiz):
    cvorU = 99999
    for i in range(MaxNiz):
        if (mstSet[i] == 0):
            if(cvorU == 99999):
                cvorU = i
            elif(NizKljuceva[i] < NizKljuceva[cvorU]):
                cvorU = i
    mstSet[cvorU] = 1
    mstSetCount += 1

    for i in range(MaxNiz):
        if (mstSet[i] == 0):
            manhattan = abs(NizX[cvorU] - NizX[i]) + abs(NizY[cvorU] - NizY[i])
            print(manhattan)
            if(NizKljuceva[i] > manhattan):
                NizKljuceva[i] = manhattan

print(mstSet)
print(NizKljuceva)

rez = 0
for x in NizKljuceva:
    rez += x
print("Tezina = ", rez)
