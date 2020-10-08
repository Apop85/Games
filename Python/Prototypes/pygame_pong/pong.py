#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# 
####
# File: pong.py
# Project: pygame_pong
#-----
# Created Date: Sunday 02.08.2020, 13:45
# Author: Apop85
#-----
# Last Modified: Sunday 02.08.2020, 13:45
#-----
# Copyright (c) 2020 Apop85
# This software is published under the MIT license.
# Check http://www.opensource.org/licenses/MIT for further informations
#-----
# Description:
####

import pygame
from sys import exit as close_game
from time import sleep
from random import randint as rng


# General setup
pygame.init()
clock = pygame.time.Clock()

# Windows setup
screen_width = 680
screen_height = 480
screen = pygame.display.set_mode((screen_width, screen_height))
pygame.display.set_caption('Pong')

# Game dimensions
ball_size = screen_width//32
paddle_height = screen_height//10*2
paddle_width = screen_width//64
paddle_distance = 10
center = {"x": screen_width//2-ball_size//2,
          "y": screen_height//2-ball_size//2}

# Shapes
ball = pygame.Rect(center["x"], center["y"], ball_size, ball_size)
right = pygame.Rect(screen_width-(paddle_width+paddle_distance), screen_height//2-paddle_height//2,paddle_width,paddle_height)
left = pygame.Rect(paddle_distance, screen_height//2-paddle_height//2,paddle_width,paddle_height)

# Text
score = { "a" : 0, "b": 0}
game_font = pygame.font.Font("freesansbold.ttf", screen_width//32)


# Speeds
max_angular_speed = 8
ballspeed = {"x" : 4, "y" : 4}
random = rng(0,1)
if random == 1:
    ballspeed["x"] *= -1
player_paddle_speed = 10
ai_paddle_speed = 3

# Colors
white = (255,255,255)
dark_grey = (35,35,35)
bright_grey = (180,180,180)



def ball_collision(ball_object, left, right):
    global ballspeed
    # Check if ball collides with top or bottom
    if ball.top <= 0 or ball.bottom >= screen_height:
        ballspeed["y"] *= -1
    # Check if ball hits left or right wall
    if ball.left <= 0 or ball.right >= screen_width:
        if ball.left <= 0:
            ballspeed["x"] = max_angular_speed
            score["b"] += 1
        else:
            ballspeed["x"] = max_angular_speed * -1
            score["a"] += 1
        ball.x = center["x"]
        ball.y = center["y"]
        ballspeed["y"] = 0
        left.centery = center["y"]
        right.centery = center["y"]
    # Check if ball hits paddles
    if ball.colliderect(left):
        # Calculate Hitpoint
        hitpoint = 100/(paddle_height)*(ball.centery - left.top)
        if hitpoint < 0:
            hitpoint = 0
        elif hitpoint > 100:
            hitpoint = 100

        # Center hit
        if left.centery + 5 > ball.centery and left.centery - 5 < ball.centery:
            ballspeed["x"] = max_angular_speed
            ballspeed["y"] = 0
        # Top hit
        elif left.centery > ball.centery:
            hitpoint = 50 - hitpoint
            if hitpoint >= 45:
                hitpoint = 40
            ballspeed["y"] = int(max_angular_speed/50*hitpoint)
            ballspeed["x"] = max_angular_speed - ballspeed["y"]
            ballspeed["y"] = int(max_angular_speed/50*hitpoint)*-1
        # Bottom hit
        else:
            hitpoint -= 50
            if hitpoint >= 45:
                hitpoint = 40
            ballspeed["y"] = int(max_angular_speed/50*hitpoint)
            ballspeed["x"] = max_angular_speed - ballspeed["y"]
    elif ball.colliderect(right):
        # Calculate Hitpoint
        hitpoint = 100/(paddle_height)*(ball.centery - right.top)
        if hitpoint < 0:
            hitpoint = 0
        elif hitpoint > 100:
            hitpoint = 100

        # Center hit
        if right.centery + 10 > ball.centery and right.centery - 10 < ball.centery:
            ballspeed["x"] = max_angular_speed*-1
            ballspeed["y"] = 0
        # Top hit
        elif right.centery > ball.centery:
            hitpoint = 50 - hitpoint
            if hitpoint >= 45:
                hitpoint = 40
            ballspeed["y"] = int(max_angular_speed/50*hitpoint)
            ballspeed["x"] = (max_angular_speed - ballspeed["y"])*-1
            ballspeed["y"] = int(max_angular_speed/50*hitpoint)*-1
        # Bottom hit
        else:
            hitpoint -= 50
            if hitpoint >= 45:
                hitpoint = 40
            ballspeed["y"] = int(max_angular_speed/50*hitpoint)
            ballspeed["x"] = (max_angular_speed - ballspeed["y"])*-1


def opponent_logic(right, ball):
    if ball.centerx > screen_width//2 or ballspeed["y"] > max_angular_speed//3*2 or ballspeed["y"] < (max_angular_speed//3*2)*-1 or ballspeed["x"] == max_angular_speed:
        if right.centery-(paddle_height/2)+20 < ball.y:
            right.centery += ai_paddle_speed
        elif right.centery+(paddle_height/2)-20 > ball.y:
            right.centery -= ai_paddle_speed
        if right.top <= 0:
            right.top = 0
        elif right.bottom >= screen_height:
            right.bottom = screen_height

# Game Loop
while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            close_game()
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_DOWN:
                player_speed = player_paddle_speed
            elif event.key == pygame.K_UP:
                player_speed = player_paddle_speed *-1
        else:
            player_speed = 0

    
    # Fill screen
    screen.fill(dark_grey)
    # Draw players
    pygame.draw.rect(screen,white, left)    
    pygame.draw.rect(screen,white, right)    
    # Ball
    pygame.draw.ellipse(screen,white, ball)    
    # Center line
    pygame.draw.aaline(screen, bright_grey, (screen_width/2,0), (screen_width/2,screen_height))
    # Text surface
    pscore = game_font.render(f'{score["a"]}', False, bright_grey)
    aiscore = game_font.render(f'{score["b"]}', False, bright_grey)
    screen.blit(pscore, (screen_width//2-screen_width//4, screen_height//2-screen_height//4))
    screen.blit(aiscore, (screen_width//2+screen_width//4, screen_height//2-screen_height//4))

    # Opponent movement
    opponent_logic(right, ball)
    
    # Animate Ball
    ball.x += ballspeed["x"]
    ball.y += ballspeed["y"]
    left.y += player_speed
    ball_collision(ball, left, right)


    # Limit player position
    if left.top <= 0:
        left.top = 0
    elif left.bottom >= screen_height:
        left.bottom = screen_height
    

    # Update window
    pygame.display.flip()
    clock.tick(60)


