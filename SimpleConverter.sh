#! /bin/bash
#set -euo pipefail

main() {
    echo "Welcome to the Simple converter!"

    while true
        do
            converter
        done
}


menu() {
    echo ""
    echo "Select an option"
    echo "0. Type '0' or 'quit' to end program"
    echo "1. Convert units"
    echo "2. Add a definition"
    echo "3. Delete a definition"
}


def_add() {
    def_re="\b[A-Za-z]+_to_[A-Za-z]+\b"
    num_re="^[+-]?[0-9]+([.][0-9]+)?$"

    echo "Enter a definition: "
    read -a user_input

    len_ui="${#user_input[@]}"

    if [ $len_ui -eq 2 ]; then
        definition="${user_input[0]}"
        constant="${user_input[1]}"

        if [[ $definition =~ $def_re ]] && [[ "$constant" =~ $num_re ]]; then
            echo "${user_input[@]}" >> definitions.txt
        else
            echo "The definition is incorrect!"
            def_add
        fi
    else
        echo "The definition is incorrect!"
        def_add
    fi
}


def_rm() {
    if [ ! -f definitions.txt ]; then
        echo "Please add a definition first!"
    else
        nline=($(wc definitions.txt))
        if [ $nline -eq 0 ]; then
            echo "Please add a definitions first!"
        else
            echo "Type the line number to delete or '0' to return"
            file_reader definitions.txt

            while true; do
                read line_number
                in_re="[^0-9]"
                if [[ "$line_number" =~ $in_re ]] || [ -z $line_number ]; then
                    echo "Enter a valid line number!"
                elif [ $line_number -eq 0 ]; then
                    break
                elif [ $line_number -le $nline ]; then
                    sed -i "${line_number}d" definitions.txt
                    break
                else
                    echo "Enter a valid line number!"
                    continue
                fi
             done
        fi
    fi
}



file_reader() {
    count=1
    while read p; do
        echo "$count. $p"
        count=$(($count+1))
    done <$1
}


convert() {
    if [ ! -f definitions.txt ]; then
        echo "Please add a definition first!"
    else
        nline=($(wc definitions.txt))
        if [ $nline -eq 0 ]; then
            echo "Please add a definitions first!"
        else
            echo "Type the line number to convert units or '0' to return"
            file_reader definitions.txt

            while true; do
                read line_number
                in_re="[^0-9]"
                if [[ "$line_number" =~ $in_re ]] || [ -z $line_number ]; then
                    echo "Enter a valid line number!"
                elif [ $line_number -eq 0 ]; then
                    break
                elif [ $line_number -le $nline ]; then
                    line=$(sed "${line_number}!d" definitions.txt)
					def=$(echo $line | cut -f1 -d " ")
					const=$(echo $line | cut -f2 -d " ")

					echo 'Enter a value to convert:'
					while true; do
						read value
                		in_re="^[+-]?[0-9]+([.][0-9]+)?$"
                		if [[ "$value" =~ $in_re ]]; then

							echo -n "Result: "; echo "$const * $value" | bc -l
								
							#echo "Result:" bc -l <<< ("$const * $value")
							converter
						else
					   		echo "Enter a float or integer value!"
					   		continue 
						fi
					done
                    
                else
                    echo "Enter a valid line number!"
                    continue
                fi
             done
        fi
    fi
}



converter() {
    menu
    read ans

    case $ans in
        0 | "quit")
            echo "Goodbye!"
            exit
            ;;
        1) convert
            ;;
        2) def_add
            ;;
        3) def_rm
            ;;
        *) echo "Invalid option!"
    esac
}


main
