#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# 
####
# File: pong.py
# Project: pong
#-----
# Created Date: Tuesday 28.07.2020, 20:41
# Author: Raffael Baldinger
#-----
# Last Modified: Tuesday 28.07.2020, 20:41
#-----
# Copyright (c) 2020 Raffael Baldinger
# This software is published under the MIT license.
# Check http://www.opensource.org/licenses/MIT for further informations
#-----
# Description: Simple pong game
####

import turtle
from time import sleep

# Set game defining variables
# Set width of the game windows
game_width=800
game_height=600
game_paddle=5
game_paddle_distance=50
game_speed=10
game_max_angle=90
game_background="black"
game_object_color="white"
game_title="Pong"
game_move_speed=10

paddle_x_right=game_width/2-game_paddle_distance
paddle_x_left=paddle_x_right*-1
scoreA=0
scoreB=0


# Define game window
windows = turtle.Screen()
windows.title(game_title)
windows.bgcolor(game_background)
windows.setup(width=game_width, height=game_height)
windows.tracer(0)

# Left
left = turtle.Turtle()
left.speed(0)
left.shape("square")
left.color(game_object_color)
left.shapesize()
left.shapesize(stretch_wid=game_paddle, stretch_len=1)
left.penup()
left.goto(paddle_x_left,0)


# Right
right = turtle.Turtle()
right.speed(0)
right.shape("square")
right.color(game_object_color)
right.shapesize(stretch_wid=game_paddle, stretch_len=1)
right.penup()
right.goto(paddle_x_right,0)

# Ball
ball = turtle.Turtle()
ball.speed(0)
ball.shape("square")
ball.color(game_object_color)
ball.penup()
ball.goto(0,0)
angle_multiplier=0.9/45*game_max_angle
speed_x=0.02
speed_y=0.02
max_speed=0.04*game_speed

# ball.deltaX=speed_x*game_speed
ball.deltaX=max_speed
ball.deltaY=0

# Score text
def update_score():
    global scoreA, scoreB
    score_text.clear()
    score_text.write("Player A: {} Player B: {}".format(scoreA, scoreB), align="center", font=("Courier", 24, "normal"))

score_text = turtle.Turtle()
score_text.speed(0)
score_text.color(game_object_color)
score_text.penup()
score_text.hideturtle()
score_text.goto(0, 260)
update_score()


def move_right_up():
    y = right.ycor()
    y += game_move_speed
    right.sety(y)

def move_right_down():
    y = right.ycor()
    y -= game_move_speed
    right.sety(y)

def move_left_up():
    y = left.ycor()
    y += game_move_speed
    left.sety(y)

def move_left_down():
    y = left.ycor()
    y -= game_move_speed
    left.sety(y)


def keybinding():
    windows.listen()
    windows.onkeypress(move_left_up, "w")
    windows.onkeypress(move_left_down, "s")
    windows.onkeypress(move_right_up, "Up")
    windows.onkeypress(move_right_down, "Down")


def move_ball():
    ball_X=ball.xcor()
    ball_Y=ball.ycor()
    ball.setx(ball_X+ball.deltaX)
    ball.sety(ball_Y+ball.deltaY)
    return (ball_X, ball_Y)

def collision_check(current_position):
    # Get position of the ball
    pos_x=current_position[0]
    pos_y=current_position[1]

    # Get position of the paddles
    paddle_dimension=game_paddle*20
    # pos_... = X axis of front pane, max y axis, min y axis
    pos_right=(paddle_x_right-20, right.ycor()+paddle_dimension/2+8, right.ycor()-paddle_dimension/2-8)
    pos_left=(paddle_x_left+20, left.ycor()+paddle_dimension/2+8, left.ycor()-paddle_dimension/2-8)

    # Check if collides with left or right side
    max_coordinates_x=game_width/2
    max_coordinates_y=game_height/2
    global scoreA, scoreB
    if pos_x <= (max_coordinates_x-10)*-1 or pos_x >= max_coordinates_x-20:
        ball.deltaX *= -1
        if pos_x < 0:
            scoreB+=1
        else:
            scoreA+=1
        if ball.deltaX < 0:
            ball.deltaX = max_speed*-1
        else:
            ball.deltaX = max_speed
        ball.deltaY = 0
        update_score()
        ball.setposition(0,0)
        right.goto(paddle_x_right,0)
        left.goto(paddle_x_left,0)
        windows.update()
        sleep(3)

    # Check if collides with top or bottom side
    if pos_y <= (max_coordinates_y-10)*-1 or pos_y >= max_coordinates_y-10:
        ball.deltaY *= -1
        if pos_y < 0:
            ball.sety((max_coordinates_y-10.1)*-1)
        else:
            ball.sety(max_coordinates_y-10.1)
    

    # Check if right pane of left paddle get hit
    if pos_left[0]-3 <= pos_x <= pos_left[0] and pos_left[1] >= pos_y >= pos_left[2]:
        hit_position=(100/paddle_dimension*(pos_y-pos_left[2]))
        translate_direction=max_speed/50*(hit_position%50)

        new_speed_y = translate_direction
        if new_speed_y > max_speed*game_speed:
            new_speed_y = max_speed*0.9
        new_speed_x = max_speed-new_speed_y

        # Check which part of the panel got hit
        if 100 >= hit_position >= 60:
            if ball.deltaY < 0:
                new_speed_y *= -1
            if ball.deltaX < 0:
                new_speed_x *= -1

        elif 0 <= hit_position <= 40:
            if ball.deltaY >= 0:
                new_speed_y *= -1
            if ball.deltaX < 0:
                new_speed_x *= -1
            
        elif 40 <= hit_position <= 60:
            new_speed_y = 0
            new_speed_x = max_speed
            if ball.deltaX < 0:
                new_speed_x *= -1

        ball.deltaX = new_speed_x
        ball.deltaY = new_speed_y
        ball.deltaX *= -1
        ball.setx(int(pos_left[0])+0.2)

    # Check if left pane of right paddle get hit
    elif pos_right[0]+3 >= pos_x >= pos_right[0] and pos_right[1] >= pos_y >= pos_right[2]:
        hit_position=(100/paddle_dimension*(pos_y-pos_right[2]))
        translate_direction=max_speed/50*(hit_position%50)
        
        new_speed_y = translate_direction
        if new_speed_y > max_speed*game_speed:
            new_speed_y = max_speed*0.9
        new_speed_x = max_speed-new_speed_y

        # Check which part of the panel got hit
        if 100 >= hit_position >= 60:
            if ball.deltaY < 0:
                new_speed_y *= -1
            if ball.deltaX < 0:
                new_speed_x *= -1

        elif 0 <= hit_position <= 40:
            if ball.deltaY >= 0:
                new_speed_y *= -1
            if ball.deltaX < 0:
                new_speed_x *= -1
            
        elif 40 <= hit_position <= 60:
            new_speed_y = 0
            new_speed_x = max_speed
            # if ball.deltaX < 0:
            #     new_speed_x *= -1

        ball.deltaX = new_speed_x
        ball.deltaY = new_speed_y
        ball.deltaX *= -1
        ball.setx(int(pos_right[0])-0.2)

# Game Loop
# try:
keybinding()

def menu():
    intro_text="Let's play\n"
    


while True:
    windows.update()
    ball_position=move_ball()
    collision_check(ball_position)

# except:
    # pass
    