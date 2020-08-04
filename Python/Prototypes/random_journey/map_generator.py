import os
def make_map(binary, width, height):
    map_data=binary[width*-1:]
    direction={0:["╝", "╔"], 1:["╗", "╚"]}
    max_length=0
    
    map=[]
    for i in range(0,len(map_data)):
        if i == 0:
            map+=[""]
            last=0
        if map_data[i] == "0":
            map[last]+=direction[1][0]
            last_len=len(map[last])
            if last == 0:
                map.insert(0,"")
            else:
                last-=1
            if last_len-1 > len(map[last]):
                map[last]+=" "*(last_len-(len(map[last])+1))
            map[last]+=direction[1][1]
        else:
            map[last]+=direction[0][0]
            last_len=len(map[last])
            last+=1
            if last > len(map)-1:
                map.insert(last,"")
            if last_len-1 > len(map[last]):
                map[last]+=" "*(last_len-(len(map[last])+1))
            map[last]+=direction[0][1]
        if len(map[last]) > max_length:
            max_length = len(map[last])

    for line in map:
        if len(line) < max_length:
            line+=" "*(max_length-len(line))
    return map

def display_game():
    filler="█"
    filler2="▒"
    print_height=9
    terminal_width=(os.get_terminal_size())[0]
    terminal_height=(os.get_terminal_size())[1]

    map_width=terminal_width-4
    map_height=int(terminal_height/3)-4
    
    map="101010101010100110101010110001010101010101010101011111"

    map_visual=make_map(map, map_width, map_height)

    # cut map to current height
    if len(map_visual) != map_height:
        for line in map_visual:
            if line[-1] == "╔" or line[-1] == "╚":
                last_index=map_visual.index(line)
                last_line=line
                break
        last_index_line=int(map_height/2)
        # Wenn der letzte Index 0 ist und die Karte noch nicht genug hoch ist
        empty_space=" "*len(map_visual[0])
        if last_index == 0 and len(map_visual) < map_height:
            while len(map_visual) < map_height:
                map_visual.insert(0,empty_space)
                map_visual+=(empty_space)
            if len(map_visual) > map_height:
                del map_visual[-1]
        # Wenn zu viele Informationen vorhanden sind
        elif len(map_visual) > map_height:
            # Ist der Zielindex kleiner als der aktuelle Index lösche index 0
            while last_index_line < map_visual.index(last_line):
                del map_visual[0]
            # Ist der Zielindex grösser als der aktuelle Index füge leere Zeilen hinzu
            while last_index_line > map_visual.index(last_line):
                map_visual.insert(0,empty_space)
            while len(map_visual) > map_height:
                del map_visual[-1]
            while len(map_visual) < map_height:
                map_visual+=(empty_space)

    for i in range(len(map_visual)-1, -1, -1):
        print(map_visual[i])
        

display_game()