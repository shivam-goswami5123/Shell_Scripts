#!/bin/bash

<<Task
This project involves creating a shell script that automates user
management tasks and backup processes in a Linux environment. The primary goal is to enable efficient management of user accounts and secure backup of specified directories. Learners will apply their knowledge of Linux commands, shell scripting, and GitHub to develop, version control, and share their script.
Task

# Loop until user chooses to exit
while true; do
        # Display menu
        echo "Select an option:"
        echo "1. Add User Account"
        echo "2. Delete User Account"
        echo "3. Modify User Account"
        echo "4. Create Group"
        echo "5. Delete Group"
        echo "6. Add User to a specific Group"
        echo "7. Remove User from a specific Group"
        echo "8. Backup+RotationPolicy+Automation of a specified directory"
        echo "9. Exit"
        read -p "Enter your choice: " choice
    

    # Case statement to handle each option
    case $choice in
        1)
            # Add User Account
            read -p "Enter username to add: " username
            if id "$username" &>/dev/null; then
                echo "Error: User '$username' already exists."
            else
                sudo useradd "$username" && echo "User '$username' added successfully." || echo "Error: Failed to add user."
            fi
            ;;
        
        2)
            # Delete User Account
            read -p "Enter username to delete: " username
            if id "$username" &>/dev/null; then
                sudo userdel -r "$username"  && echo "User '$username' deleted successfully." || echo "Error: Failed to delete user."
            else
                echo "Error: User '$username' does not exist."
            fi
            ;;
        
        3)
            # Modify User Account
            read -p "Enter username to modify: " username
            if id "$username" &>/dev/null; then
                echo "Choose modification type:"
                echo "a. Change Password"
                echo "b. Change Shell"
                echo "c. Change Home Directory"
                echo "d. Lock Account"
                echo "e. Unlock Account"
                read -p "Enter option: " mod_option

                case $mod_option in
                    a)
                        sudo passwd "$username"
                        ;;
                    b)
                        read -p "Enter new shell path (e.g., /bin/bash): " shell
                        sudo usermod -s "$shell" "$username" && echo "Shell changed to '$shell' for user '$username'."
                        ;;
                    c)
                        read -p "Enter new home directory path: " home_dir
                        sudo usermod -d "$home_dir" "$username" && echo "Home directory changed to '$home_dir' for user '$username'."
                        ;;
                    d)
                        sudo usermod -L "$username" && echo "User '$username' locked."
                        ;;
                    e)
                        sudo usermod -U "$username" && echo "User '$username' unlocked."
                        ;;
                    *)
                        echo "Invalid modification option."
                        ;;
                esac
            else
                echo "Error: User '$username' does not exist."
            fi
            ;;

        4)
            # Create Group
            read -p "Enter group name to create: " groupname
            if getent group "$groupname" &>/dev/null; then
                echo "Error: Group '$groupname' already exists."
            else
                sudo groupadd "$groupname" && echo "Group '$groupname' created successfully." || echo "Error: Failed to create group."
            fi
            ;;
        
        5)
            # Delete Group
            read -p "Enter group name to delete: " groupname
            if getent group "$groupname" &>/dev/null; then
                sudo groupdel "$groupname" && echo "Group '$groupname' deleted successfully." || echo "Error: Failed to delete group."
            else
                echo "Error: Group '$groupname' does not exist."
            fi
            ;;

        6)
            # Add User(s) to a specific Group
            read -p "Enter group name: " groupname
            if getent group "$groupname" &>/dev/null; then
                read -p "Enter usernames to add (space-separated): " -a users
                for user in "${users[@]}"; do
                    if id "$user" &>/dev/null; then
                        sudo usermod -aG "$groupname" "$user" && echo "User '$user' added to group '$groupname'." || echo "Error: Failed to add '$user' to group."
                    else
                        echo "Error: User '$user' does not exist."
                    fi
                done
            else
                echo "Error: Group '$groupname' does not exist."
            fi
            ;;
        
        7)
            # Remove User(s) from a specific Group
            read -p "Enter group name: " groupname
            if getent group "$groupname" &>/dev/null; then
                read -p "Enter usernames to remove (space-separated): " -a users
                for user in "${users[@]}"; do
                    if id "$user" &>/dev/null; then
                        sudo gpasswd -d "$user" "$groupname" && echo "User '$user' removed from group '$groupname'." || echo "Error: Failed to remove '$user' from group."
                    else
                        echo "Error: User '$user' does not exist."
                    fi
                done
            else
                echo "Error: Group '$groupname' does not exist."
            fi
            ;;
        8)
            read -p "Enter source directory complete path: " source
            read -p "Enter backup directory complete path (leave empty for current directory): " dest
            src_dir="${source}"
            backup_dir="${dest:-.}"  # Default to current directory if dest is empty

            # Validate source directory
            if [[ ! -d "$src_dir" ]]; then
                echo "Error: Source directory '$src_dir' does not exist."
                continue  # Go back to the beginning of the loop to re-prompt
            fi

            # Validate or create backup directory
            if [[ ! -d "$backup_dir" ]]; then
                echo "Backup directory '$backup_dir' does not exist. Creating it now..."
                mkdir -p "$backup_dir"  # Create the full path for the backup directory
                if [[ $? -ne 0 ]]; then
                    echo "Error: Failed to create backup directory."
                    continue  # Go back to the beginning of the loop
                fi
                echo "Backup directory created: $backup_dir"
            fi
            timestamp=$(date '+%Y-%m-%d-%H-%M-%S')

            function createBackup(){
                # Check if zip is installed
                if ! dpkg -l | grep -q zip; then
                    echo "zip is not installed. Installing..."
                    sudo apt-get update  # Update package list
                    sudo apt-get install zip -y  # Install zip
                else
                    echo "zip is already installed."
                fi

                zip -r "${backup_dir}/backup_${timestamp}.zip" "${src_dir}" 
                if [ $? -eq 0 ]; then
                    echo "Backup Generated Succesfully for ${timestamp}"
                else
                    echo "Error generating backup"
                    continue
                fi
            }

            createBackup

            function perform_rotation(){
                backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))


                if [ "${#backups[@]}" -gt 5 ] ; then
                    echo "ROTATION POLICY : RECENT 5 ENTRIES(e.g 5 days)"
                    backups_to_remove=("${backups[@]:5}")
                    for backup in "${backups_to_remove[@]}";
                    do
                        rm -f ${backup}
                    done
                fi

                #echo "${backups[@]}"
            }

            perform_rotation

            ;;
        9)
            # Exit
            echo "Exiting..."
            break
            ;;

        *)
            echo "Invalid option, please try again."
            ;;
    esac
    echo ""  # Blank line for readability
done
