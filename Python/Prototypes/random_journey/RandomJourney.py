#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# 
####
# File: txtAdventure_procedural_journey.py
# Project: Prototypes
#-----
# Created Date: Saturday 18.07.2020, 12:27
# Author: Apop85
#-----
# Last Modified: Saturday 18.07.2020, 12:27
#-----
# Copyright (c) 2020 Apop85
# This software is published under the MIT license.
# Check http://www.opensource.org/licenses/MIT for further informations
#-----
# Description: A small text adventure which will create a procedural path to travel 
####

import os
import msvcrt
import re
from random import randint as rng
from random import seed

def print_menu(title, options):
    filler="█"
    filler2="▒"
    print_height=9
    terminal_width=(os.get_terminal_size())[0]
    terminal_height=(os.get_terminal_size())[1]

    print(filler*terminal_width, end="")
    print(filler+filler2*(terminal_width-2)+filler, end="")
    for line in title:
        print(filler+filler2+line.center(terminal_width-4)+filler2+filler, end="")
        print_height+=1
    print(filler+filler2*(terminal_width-2)+filler, end="")
    print(filler*terminal_width, end="")
    print(filler+filler2*(terminal_width-2)+filler, end="")
    right_side_width=int(2*terminal_width/3)
    left_side_width=int(terminal_width/3)
    while right_side_width+left_side_width < terminal_width:
        right_side_width+=1
    for key in options.keys():
        if key != 0:
            print_height+=1
            print(filler+filler2+str(key).center(left_side_width-2) + options[key][lang].ljust(right_side_width-2)+filler2+filler, end="")
    print(filler+filler2*(terminal_width-2)+filler, end="")
    print(filler+filler2+str(0).center(left_side_width-2) + options[0][lang].ljust(right_side_width-2)+filler2+filler, end="")
    print(filler+filler2*(terminal_width-2)+filler, end="")
    print(filler*terminal_width)

    height_delta=terminal_height-print_height
    if height_delta > 1:
        for i in range(0,height_delta-2):
            print()

    pressed_key=(msvcrt.getch()).decode("ascii")
    validated, pressed_key=check_choice(options, pressed_key)
    return pressed_key, validated

def make_map(binary, width, height):
    map_data=binary[width*-1:]
    direction={1:["╝", "╔"], 2:["╗", "╚"]}
    max_length=0
    
    map=[]
    for i in range(0,len(map_data)):
        if i == 0:
            map+=[""]
            last=0
        if map_data[i] == "2":
            map[last]+=direction[2][0]
            last_len=len(map[last])
            if last == 0:
                map.insert(0,"")
            else:
                last-=1
            if last_len-1 > len(map[last]):
                map[last]+=" "*(last_len-(len(map[last])+1))
            map[last]+=direction[2][1]
        else:
            map[last]+=direction[1][0]
            last_len=len(map[last])
            last+=1
            if last > len(map)-1:
                map.insert(last,"")
            if last_len-1 > len(map[last]):
                map[last]+=" "*(last_len-(len(map[last])+1))
            map[last]+=direction[1][1]
        if len(map[last]) > max_length:
            max_length = len(map[last])

    map_corrected=[]
    for line in map:
        if len(line) < max_length:
            map_corrected+=[line+" "*(max_length-len(line))]
        else:
            map_corrected+=[line]
    return map_corrected

def display_game(map,screen,inventory,options,game_turn):
    filler="█"
    filler2="▒"

    # Line counter
    counter=10

    # Get Terminal dimensions and calculate screen part sizes
    terminal_width=(os.get_terminal_size())[0]
    terminal_height=(os.get_terminal_size())[1]

    map_width=terminal_width-4
    map_height=int(terminal_height/3)-4
    map_visual=make_map(map, map_width, map_height)

    ls_width = int(terminal_width/3*2)
    rs_width = terminal_width-ls_width
    opt_height = terminal_height-(map_height*2)

    # Split content to lines with matching lengths
    # min_line_length=ls_width-int(ls_width*0.2)
    min_line_length=5
    max_line_length=ls_width-4
    pattern=r'.{'+str(min_line_length)+r','+str(max_line_length)+r'}[ \.]'
    line_pattern=re.compile(pattern, re.DOTALL)
    content_lines=line_pattern.findall(screen)

    # cut map to current height
    if len(map_visual) != map_height and len(map_visual) > 0:
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
                map_visual+=[empty_space]
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
                map_visual+=[empty_space]
        elif len(map_visual) < map_height:
            # As long the new line is not in place add lines
            while last_index_line < map_visual.index(last_line):
                del map_visual[0]
            while last_index_line > map_visual.index(last_line): 
                map_visual.insert(0,empty_space)
            while len(map_visual) > map_height:
                del map_visual[-1]
            while len(map_visual) < map_height:
                map_visual+=[empty_space]

    elif len(map_visual) == 0:
        map_visual=[" "*map_width]*map_height

    print(filler*terminal_width, end="")
    print(filler+filler2*(terminal_width-2)+filler, end="")
    # Mrint map region
    for i in range(len(map_visual)-1,-1,-1):
        print(filler+filler2+map_visual[i].center(terminal_width-4)+filler2+filler, end="")
        counter+=1
    print(filler+filler2*(terminal_width-2)+filler, end="")
    print(filler*terminal_width, end="")
    print(filler+filler2*(terminal_width-2)+filler, end="")
    # Print content region
    for line in content_lines:
        print(filler+filler2+line.center(ls_width-3)+filler2+filler+filler2+" ".center(rs_width-4)+filler2+filler, end="")
        counter+=1
    if len(content_lines) < map_height:
        target_lines = map_height-len(content_lines) 
        for i in range(0,target_lines):
            print(filler+filler2+" ".center(ls_width-3)+filler2+filler+filler2+" ".center(rs_width-4)+filler2+filler, end="")
            counter+=1
    print(filler+filler2*(terminal_width-2)+filler, end="")
    print(filler*terminal_width, end="")
    print(filler+filler2*(terminal_width-2)+filler, end="")
    # Print options
    ls_part=int(ls_width/3)
    ls_part2=ls_width-ls_part
    for key in options.keys():
        print(filler+filler2+str(key).rjust(ls_part-3)+options[key][lang].center(ls_part2)+filler2+filler+filler2+" ".center(rs_width-4)+filler2+filler, end="")
        counter+=1
    while counter+2 < terminal_height:
        print(filler+filler2+" ".center(ls_width-3)+filler2+filler+filler2+" ".center(rs_width-4)+filler2+filler, end="")
        counter+=1
    print(filler+filler2*(terminal_width-2)+filler, end="")
    print(filler*terminal_width)

    # Read and validate presseds key
    pressed_key=(msvcrt.getch()).decode("ascii")
    validated, pressed_key=check_choice(options, pressed_key)
    return pressed_key, validated


def check_choice(options, pressed_key):
    # Check if pressed key is valid
    possible_choices=options.keys()
    try:
        if pressed_key.isdecimal() and int(pressed_key) in possible_choices:
            return True, int(pressed_key)
        else:
            return False, pressed_key
    except:
        return False, "X"

def main_menu():
    while True:
        check=False
        # Define menu options in english and german
        title=[" _____           _             ", "| __  |___ ___ _| |___ _____   ",
            "|    -| .'|   | . | . |     |  ", "|__|__|__,|_|_|___|___|_|_|_|  ",
            "    __                         ", " __|  |___ _ _ ___ ___ ___ _ _ ",
            "|  |  | . | | |  _|   | -_| | |", "|_____|___|___|_| |_|_|___|_  |",
            "                          |___|"]
        options={0:["Exit", "Beenden"],
                1:["New Game", "Neues Spiel"],
                2:["Load Game", "Spiel Laden"],
                3:["Highscore", "Highscore"],
                4:["Language", "Sprache"]}

        # Get players choice
        while not check:
            choice, check=print_menu(title, options)
        
        if choice == 0:
            return
        elif choice == 1:
            global game_seed
            game_seed=new_game()
            if game_seed != None or game_seed != "":
                current_seed=init_game(game_seed, 0)
                health=100
                start_game(current_seed)
        elif choice == 2:
            pass
        else:
            global lang
            if lang == 0:
                lang=1
            else:
                lang=0

def random_seed():
    game_seed=""
    usable_characters="abcdefghijklmnopqrstuvwxyz <>-_/*+!?)(&%ç@§°öäüÖÄÜéàèÉÀÈABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    for i in range(0,16):
        game_seed+=usable_characters[rng(0,len(usable_characters)-1)]
    return game_seed

def new_game():
        game_seed=random_seed()
        while True:
            check=False
            content = {0:["Back", "Zurück"],
                    1:["Keep seed", "Seed beibehalten"],
                    2:["Own seed", "Eigener Seed"],
                    3:["New random seed", "Neuer Zufallsseed"]}
            
            while not check:
                title=[ " _____              _____               ", "|   | |___ _ _ _   |   __|___ _____ ___ ", 
                        "| | | | -_| | | |  |  |  | .'|     | -_|", "|_|___|___|_____|  |_____|__,|_|_|_|___|",
                        "", "SEED: {}".format(game_seed), ""]
                choice, check=print_menu(title, content)
            
            if choice == 0:
                return None
            elif choice == 1:
                return game_seed
            elif choice == 2:
                message=["Enter your Seed: ", "Gewünschten Seed eingeben: "]
                game_seed=input(message[lang])
            elif choice == 3:
                game_seed=random_seed()
                continue

def game_turn_seed(game_seed, game_turn, min=0, max=100):
    seed(game_seed)
    iteration=0
    while True:
        while iteration < game_turn:
            r_seed=rng(min, max)
            iteration+=1
        r_seed=rng(min, max)
        yield r_seed


def init_game(game_seed, game_turn):
    seed_generator = game_turn_seed(game_seed, game_turn)
    for item in seed_generator:
        current_seed=item
        return current_seed

def get_perks(content_list):
    luck, gear_chance, danger = 0, 0, 0

    text = content_list[lang]

    if "luck" in content_list[2].keys():
        luck+=content_list[2]["luck"]
    if "gear_chance" in content_list[2].keys():
        gear_chance+=content_list[2]["gear_chance"]
    if "danger" in content_list[2].keys():
        danger+=content_list[2]["danger"]   
    
    return (text, luck, gear_chance, danger)

def start_game(current_seed, health=100, game_turn=0, path="", armor=0, luck=0, gear_chance=0, danger=0, inventory={}):
    while health > 0:
        checked=False
        screen_content=[]
        intro, items, left_door, right_door=get_content(current_seed)
        # Processing gathered informations
        for item in [intro, left_door, right_door]:
            new_perks = get_perks(item)
            screen_content+=[new_perks[0]]
            luck+=new_perks[1]
            gear_chance+=new_perks[2]
            danger+=new_perks[3]

        for item in items:
            new_perks = get_perks(item)
            screen_content.insert(-2,new_perks[0])
            luck+=new_perks[1]
            gear_chance+=new_perks[2]
            danger+=new_perks[3]
        
        screen_content=" ".join(screen_content)

        options = {0:["Exit", "Beenden"],
                1:["Left door", "Linke Türe"],
                2:["Right door", "Rechte Türe"]}

        while not checked:
            choice, checked = display_game(path,screen_content,inventory,options,game_turn)

        if choice in [1,2]:
            path+=str(choice)
            game_turn+=1
        elif choice == 0:
            exit()
        
        seed_generator = game_turn_seed(game_seed, game_turn)
        for random in seed_generator:
            current_seed=random
            break

def get_content(current_seed):
    seed(current_seed)
    intros=[
            ["You enter a dark cavern. ","Du betritts eine dunkle Kammer. ",{"luck":0.2,"gear_chance":-0.3, "danger":0.3}],
            ["There's a big mess here. Dirt and stones everywhere. ","Es herrscht ein totales Chaos hier. Dreck und Steine überall. ", {"luck":-0.5,"gear_chance":0.5, "danger":-0.2}],
            ["I see some light over there. I might check this!","Da drüben ist Licht! Ich sollte das untersuchen!",{"luck":0.5, "gear_chance":0.6}],
            ["It's an empty room. It doesn't look like there is something interesting here. ","Ein leerer Raum. Es sieht nicht so aus als wäre hier etwas. ",{"gear_chance":0.5}],
            ["There is a strange smell in this Room. Where does it come from? ","In diesem Raum riecht es sehr komisch. Woher könnte das kommen? ",{"luck":0.2,"gear_chance":-0.3, "danger":0.3}]
            # ["","",{}]
    ]
    random=rng(0,len(intros)-1)
    intro=intros[random]

    # items=[]
    room_items=[
                ["There is a wooden chair with restraints in the middle of the room. ","Da ist ein hölzerner Stuhl mit angebrachten Fesseln in der mitte des Raums. ",{"danger":0.2,"gear_chance":0.4}],
                ["There is no furniture in this room. ","Es gibt keine Möbel in diesem Raum. ",{"luck":-0.4, "gear_chance":-1}],
                ["A dark wooden table is pushed away from the wall. Seems like someone was searching something behind. ","Ein dunkler hölzerner Tisch wurde von der Wand weggestossen. Sieht so aus als ob da jemand etwas gesucht hat. ",{"luck":-0.1, "danger":0.2, "gear_chance":0.5}],
                ["There is a weird looking book on the floor. ","Es liegt ein komisch aussehendes Buch auf dem Boden. ",{"luck":0.3,"gear_chance":-0.2}],
                ["A rusty old shelve is attached to the left wall of the room. ","Eine rostige Ablage ist an der linken Wand im Raum befestigt. ",{"luck":0.6,"gear_chance":0.7}]
                # ["","",{}],
                # ["","",{}]
    ]
    random=rng(0,len(room_items)-1)
    # items+=[room_items[random]]
    items=[room_items[random]]

    directions=[["left", "linken"], ["right", "rechten"]]
    choosable_directions=[directions[0][lang], directions[1][lang]]
    cnt=0
    for direction in choosable_directions:
        doors=[
            ["On the {} side is a door made of metal. ".format(direction),"Auf der {} Seite ist eine Tür aus metall. ".format(direction),{}],
            ["There is a wooden door on the {} side. ".format(direction),"{} befindet sich ein hölzernes Tor. ".format((direction.capitalize()).rstrip("en")+"s"),{}],
            ["A loud scratching noise comes from the {} door. Something wants to get out. ".format(direction),"Ein lautes Kratzen ist hinter der {} Tür zu hören. Etwas möchte da raus. ".format(direction),{}],
            ["On the {} side is a small inconspicuous door. ".format(direction),"Auf der {} Seite ist eine kleine unscheinbare Türe. ".format(direction),{}],
            ["Through the crack of the {} door a little light shines out. What could be behind it? ".format(direction),"Unter der {} Türe scheint etwas licht hervor. Was könnte dahinter sein? ".format(direction),{}],
            ["There is a door made out of glass on the {} side. It seems like there is nothing behind of it. ".format(direction),"Auf der {} Seite ist eine Türe aus Glas. Es scheint nichts dahiter zu sein. ".format(direction),{}]
            # ["","",{}]
        ]
    
        random=rng(0,len(doors)-1)
        if cnt == 0:
            left_door=doors[random]
            right_door=doors[random]
            cnt=1
        else:
            while left_door == right_door:
                right_door=doors[random]
                random=rng(0,len(doors)-1)

    return intro, items, left_door, right_door


lang=0
main_menu()



