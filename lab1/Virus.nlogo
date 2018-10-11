;;Infectious Disease Model ver. 1
;;This model simulates the spread of an infectious disease traveling via contact through
;;a randomly moving population.  The user can draw walls, buildings, or obstacles in the
;;environment to simulate different environments.

breed [healthy] ;;Different breeds of turtles to show heatlh state. 
breed [infected]
breed [sick]
breed [immune]
breed [dead]

globals [ ;; Global variables.
  total-healthy
  total-sick
  total-infected
  total-immune
  total-dead
]

turtles-own [  ;; Turtle variables.
  turn-check
  wall-turn-check
  incubate
  sickness
  terminal-check
  immune-check
]

to building-draw ;; Use the mouse to draw buildings.
  if mouse-down?     
    [
      ask patch mouse-xcor mouse-ycor
        [ set pcolor grey ]]
end

to setup  ;; Initialize the model.
  clear-turtles
  pop-check
  setup-agents
  update-globals
  do-plots
  reset-ticks
end

to go  ;; Run the model.
   disease-check
   repeat 5 [ ask healthy [ fd 0.2 ] display ]
   repeat 5 [ ask infected [ fd 0.2 ] display ]
   repeat 5 [ ask sick [ fd 0.2 ] display ]
   repeat 5 [ ask immune [ fd 0.2 ] display ]
   update-globals
   do-plots
   tick
end


to setup-agents  ;;  Setup the begining number of agents and their initial states.
  set-default-shape healthy "person"
  set-default-shape infected "person"
  set-default-shape sick "person"
  set-default-shape immune "person"
  set-default-shape dead "person"
  
  ask n-of initial-healthy patches with [pcolor  = black]
     [ sprout-healthy 1
      [ set color green ] ]
      
  ask n-of initial-sick patches with [pcolor = black]
    [ sprout-sick 1
      [ set color yellow
        set sickness disease-period ] ]
      
end

to disease-check ;;  Check to see if an infected or sick turtle occupies the same patch.
  ask healthy[
    if any? other turtles-here with [color = yellow]
    [infect]
    if any? other turtles-here with [color = pink]
    [infect]
    wander
  ]
  
  ask sick[
    if any? other turtles-here with [color = green]
    [infect]
    wander
    set sickness sickness - 1
    if sickness = 0
    [live-or-die]
  ]
  
  ask infected[
    if any? other turtles-here with [color = green]
    [infect]
    wander
    set incubate incubate - 1
    if incubate = 0
    [get-sick]
  ]
  
  ask immune[wander]
  
end

to infect ;;  Infect a healthy turtle, test if it is immune and set the incubation timer if it isn't.
  set immune-check random 100
  ifelse immune-check < immune-chance
  [recover]
  [ask healthy-on patch-here[
    set breed infected
    set incubate incubation-period]
  ask infected-on patch-here [set color pink]]
  
end

to get-sick ;;  Change an infected turtle into an sick turtle and set the disease progression timer.
   set breed sick
   set color yellow
   set sickness disease-period
end

to terminate ;;  Kill a sick turtle who reaches the end of the disease progression and fails the terminal check.
  set breed dead
  set color white
end

to live-or-die ;; Test if the turtle dies from the disease.
  set terminal-check random 100
  ifelse terminal-check < terminal-chance
  [terminate]
  [recover]
end

to recover  ;;  Change turtle breed to immune.
  set breed immune
  set color grey
end


to wander ;; Random movement for agents.
    set turn-check random 20
    if turn-check > 15
    [right-turn]
    if turn-check < 5
    [left-turn]
     if [pcolor] of patch-ahead 1 != black
     [wall]

end

to wall ;;  Turn agent away from wall
    set wall-turn-check random 10
    if wall-turn-check >= 6
    [wall-right-turn]
    if wall-turn-check <= 5
    [wall-left-turn]
end

to wall-right-turn ;;Generate a random degree of turn for the wall sub-routine.
  rt 170
end

to wall-left-turn ;;Generate a random degree of turn for the wall sub-routine.
  lt 170
end
   
to right-turn ;;Generate a random degree of turn for the wander sub-routine.
  rt random-float 10
end

to left-turn   ;;Generate a random degree of turn for the wander sub-routine.
  lt random-float 10
end

to update-globals ;;Set globals to current values for reporters.
  set total-healthy (count healthy)
  set total-infected (count infected)
  set total-sick (count sick)
  set total-immune (count immune)
  set total-dead (count dead)
end

to do-plots ;; Update graph.
  set-current-plot "Population Totals"
  set-current-plot-pen "Healthy"
  plot total-healthy
  set-current-plot-pen "Infected"
  plot total-infected
  set-current-plot-pen "Sick"
  plot total-sick
  set-current-plot-pen "Immune"
  plot total-immune
  set-current-plot-pen "Dead"
  plot total-dead

end
  
to pop-check  ;; Make sure total population does not exceed total number of patches.
  if initial-healthy + initial-sick > count patches
    [ user-message (word "This simulation only has room for " count patches " agents.")
      stop ]
end
