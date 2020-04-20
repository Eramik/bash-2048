#!/bin/bash

controls=("WASDwasd")
left=("aA")
right=("dD")
top=("wW")
bottom=("sS")
declare -i score=0
gotInput=false
matrix=()
anyMerged=false
lost=false

for i in {0..15}
do
   matrix[$i]=0
done

function printMatrix {
    index=0
    for i in {0..3}
    do
        for j in {0..3}
        do
            let index=$i*4+$j
            e=${matrix[$index]}
            if [ $e == 0 ]; then
                echo -n -e ". \t"
            else 
                echo -n -e "$e \t"
            fi
        done
        echo ''
        echo ''
        echo ''
        #echo ''
    done
}

function processAction  {
    case $direction in
        'L')
            processActionLeft
            ;;
        'R')
            processActionRight
            ;;
        'T')
            processActionTop
            ;;
        'B')
            processActionBottom
    esac
    sleep .1
}

function processActionLeft {
    anyMerged=false
    for i in {0..3}
    do
        for j in {2..0}
        do
            let start=$i*4
            let ci=($start+$j) # current index
            let next=$ci+1
            #echo $ci:
            if [ ${matrix[$ci]} == ${matrix[$next]} ]; then
                #echo merge!!
                let new=${matrix[$ci]}+${matrix[$next]}
                if [ $new != 0 ]; then
                    anyMerged=true
                    score+=$new
                fi
                matrix[$ci]=$new
                matrix[$next]=0
                #echo after merge:
                #printMatrix
            elif [ ${matrix[$ci]} == 0 ]; then
                matrix[$ci]=${matrix[$next]}
                matrix[$next]=0
            fi
        done
    done
    #read -s -n 1 key
    render
    sleep .1
    if [ $anyMerged == true ]; then
        processActionLeft
    fi
}

function processActionRight {
    anyMerged=false
    for i in {0..3}
    do
        for j in {1..3}
        do
            let start=$i*4
            let ci=($start+$j) # current index
            let prev=$ci-1
            #echo $ci:
            if [ ${matrix[$ci]} == ${matrix[$prev]} ]; then
                #echo merge!!
                let new=${matrix[$ci]}+${matrix[$prev]}
                if [ $new != 0 ]; then
                    anyMerged=true
                    score+=$new
                fi
                matrix[$ci]=$new
                matrix[$prev]=0
                #echo after merge:
                #printMatrix
            elif [ ${matrix[$ci]} == 0 ]; then
                matrix[$ci]=${matrix[$prev]}
                matrix[$prev]=0
            fi
        done
    done
    #read -s -n 1 key
    render
    if [ $anyMerged == true ]; then
        processActionRight
    fi
}

function processActionBottom {
    anyMerged=false
    for i in {1..3}
    do
        for j in {0..3}
        do
            let start=$i*4
            let ci=($start+$j) # current index
            let prev=$ci-4
            #echo $ci:
            if [ ${matrix[$ci]} == ${matrix[$prev]} ]; then
                #echo merge!!
                let new=${matrix[$ci]}+${matrix[$prev]}
                if [ $new != 0 ]; then
                    anyMerged=true
                    score+=$new
                fi
                matrix[$ci]=$new
                matrix[$prev]=0
                #echo after merge:
                #printMatrix
            elif [ ${matrix[$ci]} == 0 ]; then
                matrix[$ci]=${matrix[$prev]}
                matrix[$prev]=0
            fi
        done
    done
    #read -s -n 1 key
    render
    if [ $anyMerged == true ]; then
        processActionBottom
    fi
}

function checkForLoseOrWin {
    lost=true
    #echo checking!!!!!
    for i in {0..15}
    do
        #echo current elemenet is ${matrix[$i]}
        if [ ${matrix[$i]} == 0 ]; then
            #echo didnt lose yetttt
            lost=false
        elif [ ${matrix[$i]} == 2048 ]; then
            #echo won!!!!!!!!
            #read -s -n 1 key
            handleWon
            return
        fi
    done
    #echo lost is $lost
    if [ $lost == true ]; then
        #echo GAME OVER
        read -s -n 1 key

        gameOver
        return
    fi
}

function processActionTop {
    anyMerged=false
    for i in {3..1}
    do
        for j in {0..3}
        do
            let start=$i*4
            let ci=($start+$j) # current index
            let next=$ci-4
            #echo $ci:
            if [ ${matrix[$ci]} == ${matrix[$next]} ]; then
                #echo merge!!
                let new=${matrix[$ci]}+${matrix[$next]}
                if [ $new != 0 ]; then
                    anyMerged=true
                    score+=$new
                fi
                matrix[$next]=$new
                matrix[$ci]=0
                #echo after merge:
                #printMatrix
            elif [ ${matrix[$next]} == 0 ]; then
                matrix[$next]=${matrix[$ci]}
                matrix[$ci]=0
            fi
        done
    done
    #read -s -n 1 key
    render
    sleep .1
    if [ $anyMerged == true ]; then
        processActionTop
    fi
}


function spawnNewTile {
    let tileIndex=$(( RANDOM % 16 ))
    while [ ${matrix[$tileIndex]} != 0 ]
    do
        let tileIndex=$(( RANDOM % 16 ))
    done

    let tilePower=$(( (RANDOM % 2) +1 ))
    let tileValue=(2**$tilePower)
    matrix[$tileIndex]=$tileValue
}

function gameOver {
    clear
    echo 'You lost! Your score is' $score

    for i in {0..15}
    do
        matrix[$i]=0
    done

    score=0

    echo 'Press any key to start a new game...'
    read -s -n 1 key
    runGame
}

function handleWon {
    clear
    echo 'You won! Your score is' $score

    for i in {0..15}
    do
        matrix[$i]=0
    done

    score=0

    echo 'Press any key to start a new game...'
    read -s -n 1 key
    runGame
}

function welcomeMessage {
    clear
    echo 'Welcome to 2048 terminal game!'
    echo ''
    echo 'Use WASD to move the tiles.'
    echo 'Press CTRL+C to stop the game.'
    echo 'Get 2048 tile to win!'
    echo ''
    echo 'Press any key to start...'
}

function getDirection {
    gotInput=false
    if [[ "${left[@]}" =~ "${key}" ]]; then
        gotInput=true
        direction="L"
        return
    fi

    if [[ "${right[@]}" =~ "${key}" ]]; then
        gotInput=true
        direction="R"
        return
    fi

    if [[ "${bottom[@]}" =~ "${key}" ]]; then
        gotInput=true
        direction="B"
        return
    fi

    if [[ "${top[@]}" =~ "${key}" ]]; then
        gotInput=true
        direction="T"
        return
    fi
}

function printHeadline {
    echo "Score: $score"
}

function render {
    clear
    printHeadline
    echo ""

    printMatrix
}

function runGame {
    spawnNewTile
    while :; do
        render
        read -s -n 1 key

        getDirection

        if [[ $gotInput == false ]]; then
            continue
        else
            processAction
            spawnNewTile
            checkForLoseOrWin
        fi

        echo $direction
    done
}

welcomeMessage
runGame
