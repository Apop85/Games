#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# 
####
# File: flappybird.py
# Project: flappy_bird
#-----
# Created Date: Sunday 02.08.2020, 20:03
# Author: Apop85
#-----
# Last Modified: Sunday 02.08.2020, 20:03
#-----
# Copyright (c) 2020 Apop85
# This software is published under the MIT license.
# Check http://www.opensource.org/licenses/MIT for further informations
#-----
# Description:
####

import pygame
import os
from sys import exit as quit_game
from random import choice as randomChoice
from random import randint as rng

# Setup game
pygame.init()
clock = pygame.time.Clock()
game_fps = 30

# Screen settings
windows_width = 576//2
windows_height = 1024//2
screen = pygame.display.set_mode((windows_width, windows_height))

# Image sizes
player = windows_width//10
tube_width = windows_width//6
floor_height = windows_width//12

# Background image
background = pygame.image.load("assets/bg_day.png").convert_alpha()
background_height = background.get_height()
background_width = background.get_width()
# Calculate scale for images
scale = background_height/windows_height
background_width_scaled = int(background_width*scale)
# Transform background
background = pygame.transform.scale(background, (background_width_scaled, windows_height))
backgroundX = 0
background_offset = int(background_width*scale)

# Start screen
start_screen = pygame.image.load("assets/mainscreen.png").convert_alpha()
start_screen_height = start_screen.get_height()
start_screen_width = start_screen.get_width()
start_screen_scale = start_screen_height/windows_height
# Calculate needed scaling
start_screen_width_scaled = int(start_screen_width/start_screen_scale)
# Scale start screen
start_screen = pygame.transform.scale(start_screen, (start_screen_width_scaled, windows_height))


# Variables
gravity = 1.5/scale
bird_movement = 0
game_active = False
pipe_counter = 0
highscore = 0

# Floor image
floor = pygame.image.load("assets/floor.png").convert_alpha()
floor_height = floor.get_height()/scale
floor_width = floor.get_width()/scale
# Scale floor image
floor = pygame.transform.scale(floor, (int(floor_width), int(floor_height)))
floorX = 0
floor_offset = int(floor_width)

# Pipes image
pipes = { "brown": "assets/tube_a.png",
          "green": "assets/tube_b.png" }
pipe_color = randomChoice([item for item in pipes.keys()])
# Load random colored pipes
pipe = pygame.image.load(pipes[pipe_color])
pipe_height = pipe.get_height()/scale
pipe_width = pipe.get_width()/scale
pipe = pygame.transform.scale(pipe, (int(pipe_width), int(pipe_height)))
# Create empty pipe list
pipe_list = []
# Create spawn event
spawnpipe = pygame.USEREVENT
pygame.time.set_timer(spawnpipe, rng(1200,2400))


# Bird image
birds = {"blue":["assets/bird_blue_up.png", "assets/bird_blue_mid.png", "assets/bird_blue_down.png"],
         "orange":["assets/bird_orange_up.png", "assets/bird_orange_mid.png", "assets/bird_orange_down.png"],
         "red":["assets/bird_red_up.png", "assets/bird_red_mid.png", "assets/bird_red_down.png"],
        }
choices = [item for item in birds.keys()]
bird_color = randomChoice(choices)
# Load random bird color
bird_low = pygame.image.load(birds[bird_color][2]).convert_alpha()
bird_mid = pygame.image.load(birds[bird_color][1]).convert_alpha()
bird_top = pygame.image.load(birds[bird_color][0]).convert_alpha()
bird_height = bird_low.get_height()
bird_width = bird_low.get_width()
# Calculate scaleds height
bird_height_scaled = int(bird_height/(scale*2))
bird_width_scaled = int(bird_width/(scale*2))
# Scale images
bird_low = pygame.transform.scale(bird_low, (bird_width_scaled, bird_height_scaled))
bird_mid = pygame.transform.scale(bird_mid, (bird_width_scaled, bird_height_scaled))
bird_top = pygame.transform.scale(bird_top, (bird_width_scaled, bird_height_scaled))
# Animation frames
bird_frames = [ bird_low, bird_mid, bird_top ]
bird_index = 0
forward = True
# Scale current image
bird = pygame.transform.scale(bird_frames[bird_index], (bird_width_scaled, bird_height_scaled))
# Initial bird position
birdX = int(windows_width/8)
birdY = int(windows_height*0.23)
# Create collision box
bird_collision_box = bird.get_rect(topleft = (birdX, birdY))
# Create animation event
flapflap = pygame.USEREVENT + 1
pygame.time.set_timer(flapflap, rng(120,240))

# Load game font
game_font = pygame.font.Font("freesansbold.ttf", int(40/scale))

# Create score-check event
check_passed_pipes = pygame.USEREVENT + 2
pygame.time.set_timer(check_passed_pipes, 25)



def display_score(state):
    global highscore
    # Render score text
    text = "Score: {} ".format(pipe_counter)
    score_surface = game_font.render(text, True, (255,255,255))
    score_rect = score_surface.get_rect(center = (windows_width/2, 20))
    screen.blit(score_surface, score_rect)
    if state == "start_screen":
        # Update high score
        if pipe_counter > highscore:
            highscore = pipe_counter
        # Show high score
        text = "High Score: {} ".format(highscore)
        highscore_surface = game_font.render(text, True, (255,255,255))
        highscore_rect = highscore_surface.get_rect(center = (windows_width/2, windows_height*0.92))
        screen.blit(highscore_surface, highscore_rect)


def draw_background():
    # Create background tiles
    offset = 0
    amount = int(windows_width//background_offset+1)

    for i in range(0,amount+1):
        screen.blit(background, (backgroundX+offset,0))
        offset += int(background_offset)

def draw_floor():
    # Create floor tiles
    offset = 0
    amount = int(windows_width//floor_offset+1)

    for i in range(0,amount):
        screen.blit(floor, (floorX+offset,windows_height-floor_height))
        offset += int(floor_offset)

def create_pipe():
    # Create pipes
    random_height = rng(int(windows_height-int(windows_height*0.75)), int(windows_height-50))
    pipe_bottom = pipe.get_rect(midtop = (windows_width+pipe_width, random_height))
    pipe_top = pipe.get_rect(midbottom = (windows_width+pipe_width, random_height-rng(200,300)//scale))
    return (pipe_bottom, pipe_top)

def move_pipes(pipes):
    # Iterate pipe_list and change centerx of each
    for item in pipes:
        for position in item:
            position.centerx -= 5
    return pipes

def draw_pipes(pipes):
    # Draw pipes to screen
    for item in pipes:
        screen.blit(pipe, item[0])
        flip_pipe = pygame.transform.flip(pipe, False, True)
        screen.blit(flip_pipe, item[1])

def check_collision(pipes):
    for pipe in pipes:
        # Check if bird collides with pipes
        if bird_collision_box.colliderect(pipe[0]) or bird_collision_box.colliderect(pipe[1]):
            return False
    # Check if bird collides with roof or floor
    if bird_collision_box.top <= -50 or bird_collision_box.bottom >= windows_height-int(floor_height/scale):
        return False
    return True

def rotate_bird(bird_surface):
    # Rotate bird trough speed variable
    new_bird = pygame.transform.rotozoom(bird_surface, -bird_movement * 3, 1)
    return new_bird

def animate_bird():
    # Load next bird animation frame
    new_bird = bird_frames[bird_index]
    new_bird_collision = new_bird.get_rect(center = (int(bird_height/scale), bird_collision_box.centery))
    return new_bird, new_bird_collision

def count_pipes():
    global pipe_counter, pipe_list
    # If a pipe is past center of bird by +/- 2px
    if (pipe_list[0][0].midright)[0]-2 < bird_collision_box.centerx < (pipe_list[0][0].midright)[0]+2: 
        pipe_counter += 1 
    # If a pipes mid right X coordinate is less 0 delete from list
    if (pipe_list[0][0].midright)[0] < 0:
        del pipe_list[0]

# Game loop
while True:
    # Handle events
    for event in pygame.event.get():
        # Window get closed?
        if event.type == pygame.QUIT:
            pygame.quit()
            quit_game()
 
        # Check is key is pressed
        if event.type == pygame.KEYDOWN:
            # If spacebar while game is running change gravity
            if event.key == pygame.K_SPACE and game_active:
                bird_movement = 0
                bird_movement -= gravity+12
            # On title screen start new game
            elif not game_active:
                pipe_list.clear()
                bird_collision_box.topleft = (birdX, birdY)
                bird_movement = 0
                pipe_counter = 0
                game_active = True

        # Spawn pipes if spawnpipe event triggered
        if event.type == spawnpipe:
            pipe_list.append(create_pipe())
            pygame.time.set_timer(spawnpipe, rng(1200,2400))

        # Animate bird on flapflap event
        if event.type == flapflap:
            bird, bird_collision_box = animate_bird()
            # Go up and down the index
            if bird_index == 2:
                forward = False
            elif bird_index == 0:
                forward = True
            if forward:
                bird_index += 1
            else:
                bird_index -= 1
            # Set new timer
            pygame.time.set_timer(flapflap, rng(120,240))

        # Check passed pipes on check_passed_pipes event
        if event.type == check_passed_pipes:
            if len(pipe_list) > 0:
                count_pipes()


    # Enable background
    backgroundX -= 1
    draw_background()
    # Reset background position if first item is not visible anymore
    if backgroundX <= background_offset * -1:
        backgroundX += background_offset
    
    floorX -= 5
    draw_floor()
    # Reset floor position if first item is not visible anymore
    if floorX <= floor_offset * -1:
        floorX += floor_offset

    # Active game
    if game_active:
        # Bird logic
        bird_movement += gravity
        rotated_bird = rotate_bird(bird)
        bird_collision_box.centery += bird_movement
        screen.blit(rotated_bird, bird_collision_box)

        # Pipes logic
        pipes = move_pipes(pipe_list)
        draw_pipes(pipe_list)

        # Game logic
        game_active = check_collision(pipe_list)
        display_score("main_game")
    else:
        # Start screen
        bird_collision_box.centery = birdY
        screen.blit(bird, bird_collision_box)
        screen.blit(start_screen, (0,0))
        display_score("start_screen")

    # Update screen
    pygame.display.update()
    clock.tick(game_fps)