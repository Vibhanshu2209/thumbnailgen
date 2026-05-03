import random 

x = {
    "a" : "SOme",
    "b" : "SOME",
    "c" : "some",
}

def get_value(y: str = None):
    i = list(x.keys())[random.randint(0,len(x.keys())-1)]
    return x[y] if y else x[i]


print(get_value())
