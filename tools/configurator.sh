#!/bin/bash

# VARIABLES SECTION

source /app/libexec/global.sh
source /app/libexec/functions.sh

# DIALOG SECTION

# Configurator Option Tree

# Welcome
#     - RetroArch Presets
#       - Change Rewind Setting
#         - Enable/Disable Rewind
#       - RetroAchivement Login
#         - Login prompt
#     - Dolphin Presets
#       - Enable/Disable Custom Input Textures
#     - Emulator Options (Behind one-time power user warning dialog)
#       - Launch RetroArch
#       - Launch Cemu
#       - Launch Citra
#       - Launch Dolphin
#       - Launch Duckstation
#       - Launch MelonDS
#       - Launch PCSX2
#       - Launch PPSSPP
#       - Launch Primehack
#       - Launch RPCS3
#       - Launch XEMU
#       - Launch Yuzu
#     - Tools and Troubleshooting
#       - Move RetroDECK or subfolders
#       - Multi-file game check
#       - Basic BIOS file check
#       - Advanced BIOS file check
#       - Compress Games
#         - Manual single-game selection
#         - Multi-file compression (CHD)
#       - Download ES themes
#       - Download PS3 firmware
#       - Install RetroDECK controller profile
#       - Backup RetroDECK userdata
#     - Reset
#       - Reset Specific Emulator
#           - Reset RetroArch
#           - Reset Cemu
#           - Reset Citra
#           - Reset Dolphin
#           - Reset Duckstation
#           - Reset MelonDS
#           - Reset PCSX2
#           - Reset PPSSPP
#           - Reset Primehack
#           - Reset RPCS3
#           - Reset XEMU
#           - Reset Yuzu
#       - Reset All Emulators
#       - Reset RetroDECK

# DIALOG TREE FUNCTIONS

configurator_reset_dialog() {
  choice=$(zenity --list --title="RetroDECK Configurator Utility - Reset Options" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --column="Choice" --column="Action" \
  "Reset Specific Emulator" "Reset only one specific emulator to default settings" \
  "Reset All Emulators" "Reset all emulators to default settings" \
  "Reset RetroDECK" "Reset RetroDECK to default settings" )

  case $choice in

  "Reset Specific Emulator" )
    emulator_to_reset=$(zenity --list \
    --title "RetroDECK Configurator Utility - Reset Specific Standalone Emulator" --cancel-label="Back" \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
    --text="Which emulator do you want to reset to default?" \
    --column="Emulator" --column="Action" \
    "RetroArch" "Reset RetroArch to default settings" \
    "Cemu" "Reset Cemu to default settings" \
    "Citra" "Reset Citra to default settings" \
    "Dolphin" "Reset Dolphin to default settings" \
    "Duckstation" "Reset Duckstation to default settings" \
    "MelonDS" "Reset MelonDS to default settings" \
    "PCSX2" "Reset PCSX2 to default settings" \
    "PPSSPP" "Reset PPSSPP to default settings" \
    "Primehack" "Reset Primehack to default settings" \
    "RPCS3" "Reset RPCS3 to default settings" \
    "XEMU" "Reset XEMU to default settings" \
    "Yuzu" "Reset Yuzu to default settings" )

    case $emulator_to_reset in

    "RetroArch" | "XEMU" ) # Emulators that require network access
      if [[ $(configurator_reset_confirmation_dialog "$emulator_to_reset" "Are you sure you want to reset the $emulator_to_reset emulator to default settings?\n\nThis process cannot be undone.") == "true" ]]; then
        if [[ $(check_network_connectivity) == "true" ]]; then
          prepare_emulator "reset" "$emulator_to_reset" "configurator"
          configurator_process_complete_dialog "resetting $emulator_to_reset"
        else
          configurator_generic_dialog "You do not appear to be connected to a network with internet access.\n\nThe $emulator_to_reset reset process requires some files from the internet to function properly.\n\nPlease retry this process once a network connection is available."
          configurator_reset_dialog
        fi
      else
        configurator_generic_dialog "Reset process cancelled."
        configurator_reset_dialog
      fi
    ;;

    "Cemu" | "Citra" | "Dolphin" | "Duckstation" | "MelonDS" | "PCSX2" | "PPSSPP" | "Primehack" | "RPCS3" | "Ryujinx" | "Yuzu" )
      if [[ $(configurator_reset_confirmation_dialog "$emulator_to_reset" "Are you sure you want to reset the $emulator_to_reset emulator to default settings?\n\nThis process cannot be undone.") == "true" ]]; then
        prepare_emulator "reset" "$emulator_to_reset" "configurator"
        configurator_process_complete_dialog "resetting $emulator_to_reset"
      else
        configurator_generic_dialog "Reset process cancelled."
        configurator_reset_dialog
      fi
    ;;

    "" ) # No selection made or Back button clicked
      configurator_reset_dialog
    ;;

    esac
  ;;

"Reset All Emulators" )
  if [[ $(configurator_reset_confirmation_dialog "all emulators" "Are you sure you want to reset all emulators to default settings?\n\nThis process cannot be undone.") == "true" ]]; then
    if [[ $(check_network_connectivity) == "true" ]]; then
      prepare_emulator "reset" "all"
      configurator_process_complete_dialog "resetting all emulators"
    else
      configurator_generic_dialog "You do not appear to be connected to a network with internet access.\n\nThe all-emulator reset process requires some files from the internet to function properly.\n\nPlease retry this process once a network connection is available."
      configurator_reset_dialog
    fi
  else
    configurator_generic_dialog "Reset process cancelled."
    configurator_reset_dialog
  fi
;;

"Reset RetroDECK" )
  if [[ $(configurator_reset_confirmation_dialog "RetroDECK" "Are you sure you want to reset RetroDECK entirely?\n\nThis process cannot be undone.") == "true" ]]; then
    zenity --icon-name=net.retrodeck.retrodeck --info --no-wrap \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator Utility - Reset RetroDECK" \
    --text="You are resetting RetroDECK to its default state.\n\nAfter the process is complete you will need to exit RetroDECK and run it again, where you will go through the initial setup process."
    rm -f "$lockfile"
    rm -f "$rd_conf"
    configurator_process_complete_dialog "resetting RetroDECK"
  else
    configurator_generic_dialog "Reset process cancelled."
    configurator_reset_dialog
  fi
;;

"" ) # No selection made or Back button clicked
  configurator_welcome_dialog
;;

  esac
}

configurator_retroachivement_dialog() {
  login=$(zenity --forms --title="RetroDECK Configurator Utility - RetroArch RetroAchievements Login" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --text="Enter your RetroAchievements Account details.\n\nBe aware that this tool cannot verify your login details and currently only supports logging in with RetroArch.\nFor registration and more info visit\nhttps://retroachievements.org/\n" \
  --separator="=SEP=" \
  --add-entry="Username" \
  --add-password="Password")

  if [ $? == 0 ]; then # OK button clicked
    arrIN=(${login//=SEP=/ })
    user=${arrIN[0]}
    pass=${arrIN[1]}

    set_setting_value $raconf cheevos_enable true retroarch
    set_setting_value $raconf cheevos_username $user retroarch
    set_setting_value $raconf cheevos_password $pass retroarch

    configurator_process_complete_dialog "logging in to RetroArch RetroAchievements"
  else
    configurator_welcome_dialog
  fi
}

configurator_power_user_warning_dialog() {
  if [[ $power_user_warning == "true" ]]; then
    choice=$(zenity --icon-name=net.retrodeck.retrodeck --info --no-wrap --ok-label="Yes" --extra-button="No" --extra-button="Never show this again" \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Desktop Mode Warning" \
    --text="Making manual changes to an emulators configuration may create serious issues,\nand some settings may be overwitten during RetroDECK updates.\n\nSome standalone emulator functions may not work properly outside of Desktop mode.\n\nPlease continue only if you know what you're doing.\n\nDo you want to continue?")
  fi
  rc=$? # Capture return code, as "Yes" button has no text value
  if [[ $rc == "0" ]]; then # If user clicked "Yes"
    configurator_power_user_changes_dialog
  else # If any button other than "Yes" was clicked
    if [[ $choice == "No" ]]; then
      configurator_welcome_dialog
    elif [[ $choice == "Never show this again" ]]; then
      set_setting_value $rd_conf "power_user_warning" "false" retrodeck "options" # Store desktop mode warning variable for future checks
      conf_read
      configurator_power_user_changes_dialog
    fi
  fi
}

configurator_power_user_changes_dialog() {
  emulator=$(zenity --list \
  --title "RetroDECK Configurator Utility - Emulator Options" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --text="Which emulator do you want to launch?" \
  --hide-header \
  --column=emulator \
  "RetroArch" \
  "Cemu" \
  "Citra" \
  "Dolphin" \
  "Duckstation" \
  "MelonDS" \
  "PCSX2" \
  "PPSSPP" \
  "Primehack" \
  "RPCS3" \
  "XEMU" \
  "Yuzu")

  case $emulator in

  "RetroArch" )
    retroarch
  ;;

  "Cemu" )
    Cemu-wrapper
  ;;

  "Citra" )
    citra-qt
  ;;

  "Dolphin" )
    dolphin-emu
  ;;

  "Duckstation" )
    duckstation-qt
  ;;

  "MelonDS" )
    melonDS
  ;;

  "PCSX2" )
    pcsx2-qt
  ;;

  "PPSSPP" )
    PPSSPPSDL
  ;;

  "Primehack" )
    primehack-wrapper
  ;;

  "RPCS3" )
    rpcs3
  ;;

  "XEMU" )
    xemu
  ;;

  "Yuzu" )
    yuzu
  ;;

  "" ) # No selection made or Back button clicked
    configurator_welcome_dialog
  ;;

  esac
}

configurator_retroarch_rewind_dialog() {
  if [[ $(get_setting_value $raconf rewind_enable retroarch) == "true" ]]; then
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - RetroArch Rewind" \
    --text="Rewind is currently enabled. Do you want to disable it?."

    if [ $? == 0 ]
    then
      set_setting_value $raconf "rewind_enable" "false" retroarch
      configurator_process_complete_dialog "disabling Rewind"
    else
      configurator_retroarch_presets_dialog
    fi
  else
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - RetroArch Rewind" \
    --text="Rewind is currently disabled, do you want to enable it?\n\nNOTE:\nThis may impact performance on some more demanding systems."

    if [ $? == 0 ]
    then
      set_setting_value $raconf "rewind_enable" "true" retroarch
      configurator_process_complete_dialog "enabling Rewind"
    else
      configurator_retroarch_presets_dialog
    fi
  fi
}

configurator_retroarch_presets_dialog() {
  choice=$(zenity --list --title="RetroDECK Configurator Utility - RetroArch Options" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --column="Choice" --column="Action" \
  "Change Rewind Setting" "Enable or disable the Rewind function in RetroArch." \
  "RetroAchievements Login" "Log into the RetroAchievements service in RetroArch." )

  case $choice in

  "Change Rewind Setting" )
    configurator_retroarch_rewind_dialog
  ;;

  "RetroAchievements Login" )
    configurator_retroachivement_dialog
  ;;

  "" ) # No selection made or Back button clicked
    configurator_welcome_dialog
  ;;

  esac
}

configurator_dolphin_presets_dialog() {
  choice=$(zenity --list --title="RetroDECK Configurator Utility - Dolphin Options" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --column="Choice" --column="Action" \
  "Change Custom Input Textures Setting" "Enable or disable custom input textures for supported games in Dolphin." )

  case $choice in

  "Change Custom Input Textures Setting" )
    configurator_dolphin_input_textures_dialog
  ;;

  "" ) # No selection made or Back button clicked
    configurator_welcome_dialog
  ;;

  esac
}

configurator_dolphin_input_textures_dialog() {
  if [[ -d "/var/data/dolphin-emu/Load/DynamicInputTextures" ]]; then
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - Dolphin Custom Input Textures" \
    --text="Custom input textures are currently enabled. Do you want to disable them?."

    if [ $? == 0 ]
    then
      set_setting_value $dolphingfxconf "HiresTextures" "False" dolphin
      rm -rf "/var/data/dolphin-emu/Load/DynamicInputTextures"
      configurator_process_complete_dialog "disabling Dolphin custom input textures"
    else
      configurator_dolphin_presets_dialog
    fi
  else
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - Dolphin Custom Input Textures" \
    --text="Custom input textures are currently disabled. Do you want to enable them?.\n\nThis process may take several minutes to complete."

    if [ $? == 0 ]
    then
      set_setting_value $dolphingfxconf "HiresTextures" "True" dolphin
      (
        mkdir "/var/data/dolphin-emu/Load/DynamicInputTextures"
        cp -rf "/app/retrodeck/extras/DynamicInputTextures/*" "/var/data/dolphin-emu/Load/DynamicInputTextures/"
      ) |
      zenity --icon-name=net.retrodeck.retrodeck --progress --no-cancel --pulsate --auto-close \
      --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
      --title "RetroDECK Configurator Utility - Dolphin Custom Input Textures Install"
      configurator_process_complete_dialog "enabling Dolphin custom input textures"
    else
      configurator_dolphin_presets_dialog
    fi
  fi
}

configurator_compress_single_game_dialog() {
  local file=$(file_browse "Game to compress")
  if [[ ! -z "$file" ]]; then
    local compatible_compression_format=$(find_compatible_compression_format "$file")
    if [[ ! $compatible_compression_format == "none" ]]; then
      local post_compression_cleanup=$(configurator_compression_cleanup_dialog)
      (
      if [[ $compatible_compression_format == "chd" ]]; then
        if [[ $(validate_for_chd "$file") == "true" ]]; then
          echo "# Compressing $(basename "$file") to $compatible_compression_format format"
          compress_game "chd" "$file"
          if [[ $post_compression_cleanup == "true" ]]; then # Remove file(s) if requested
            if [[ "$file" == *".cue" ]]; then
              local cue_bin_files=$(grep -o -P "(?<=FILE \").*(?=\".*$)" "$file")
              local file_path=$(dirname "$(realpath "$file")")
              while IFS= read -r line
              do
                rm -f "$file_path/$line"
              done < <(printf '%s\n' "$cue_bin_files")
              rm -f "$file"
            else
              rm -f "$file"
            fi
          fi
        fi
      else
        echo "# Compressing $(basename "$file") to $compatible_compression_format format"
        compress_game "$compatible_compression_format" "$file"
        if [[ $post_compression_cleanup == "true" ]]; then # Remove file(s) if requested
          rm -f "$file"
        fi
      fi
      ) |
      zenity --icon-name=net.retrodeck.retrodeck --progress --no-cancel --pulsate --auto-close \
      --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
      --title "RetroDECK Configurator Utility - Compression in Progress"
      configurator_generic_dialog "The compression process is complete!"
      configurator_compress_games_dialog

    else
      configurator_generic_dialog "The selected file does not have any compatible compressed format."
      configurator_compress_games_dialog
    fi
  else
    configurator_generic_dialog "No file selected, returning to main menu"
    configurator_welcome_dialog
  fi
}

configurator_compress_some_games_dialog() {
  # This dialog will display any games it finds to be compressable, from the systems listed under each compression type in compression_targets.cfg

  local compressable_games_list=()
  local all_compressable_games=()
  local games_to_compress=()

  if [[ ! -z "$1" ]]; then
    local compression_format="$1"
  else
    local compression_format="all"
  fi

  if [[ $compression_format == "all" ]]; then
    local compressable_systems_list=$(cat $compression_targets | sed '/^$/d' | sed '/^\[/d')
  else
    local compressable_systems_list=$(sed -n '/\['"$compression_format"'\]/, /\[/{ /\['"$compression_format"'\]/! { /\[/! p } }' $compression_targets | sed '/^$/d')
  fi

  while IFS= read -r system # Find and validate all games that are able to be compressed with this compression type
  do
    compression_candidates=$(find "$roms_folder/$system" -type f -not -iname "*.txt")
    if [[ ! -z $compression_candidates ]]; then
      while IFS= read -r game
      do
        local compatible_compression_format=$(find_compatible_compression_format "$game")
        if [[ $compression_format == "chd" ]]; then
          if [[ $compatible_compression_format == "chd" ]]; then
            all_compressable_games=("${all_compressable_games[@]}" "$game")
            compressable_games_list=("${compressable_games_list[@]}" "false" "${game#$roms_folder}" "$game")
          fi
        elif [[ $compression_format == "zip" ]]; then
          if [[ $compatible_compression_format == "zip" ]]; then
            all_compressable_games=("${all_compressable_games[@]}" "$game")
            compressable_games_list=("${compressable_games_list[@]}" "false" "${game#$roms_folder}" "$game")
          fi
        elif [[ $compression_format == "rvz" ]]; then
          if [[ $compatible_compression_format == "rvz" ]]; then
            all_compressable_games=("${all_compressable_games[@]}" "$game")
            compressable_games_list=("${compressable_games_list[@]}" "false" "${game#$roms_folder}" "$game")
          fi
        elif [[ $compression_format == "all" ]]; then
          if [[ ! $compatible_compression_format == "none" ]]; then
            all_compressable_games=("${all_compressable_games[@]}" "$game")
            compressable_games_list=("${compressable_games_list[@]}" "false" "${game#$roms_folder}" "$game")
          fi
        fi
      done < <(printf '%s\n' "$compression_candidates")
    fi
  done < <(printf '%s\n' "$compressable_systems_list")

  choice=$(zenity \
      --list --width=1200 --height=720 \
      --checklist --hide-column=3 --ok-label="Compress Selected" --extra-button="Compress All" \
      --separator="," --print-column=3 \
      --text="Choose which games to compress:" \
      --column "Compress?" \
      --column "Game" \
      --column "Game Full Path" \
      "${compressable_games_list[@]}")

  local rc=$?
  if [[ $rc == "0" && ! -z $choice ]]; then # User clicked "Compress Selected" with at least one game selected
    IFS="," read -ra games_to_compress <<< "$choice"
    local total_games_to_compress=${#games_to_compress[@]}
    local games_left_to_compress=$total_games_to_compress
  elif [[ ! -z $choice ]]; then # User clicked "Compress All"
    games_to_compress=("${all_compressable_games[@]}")
    local total_games_to_compress=${#all_compressable_games[@]}
    local games_left_to_compress=$total_games_to_compress
  fi

  if [[ ! $(echo "${#games_to_compress[@]}") == "0" ]]; then
    local post_compression_cleanup=$(configurator_compression_cleanup_dialog)
    (
    for file in "${games_to_compress[@]}"; do
      local compression_format=$(find_compatible_compression_format "$file")
      echo "# Compressing $(basename "$file") into $compression_format format" # Update Zenity dialog text
      progress=$(( 100 - (( 100 / "$total_games_to_compress" ) * "$games_left_to_compress" )))
      echo $progress
      games_left_to_compress=$((games_left_to_compress-1))
      compress_game "$compression_format" "$file"
      if [[ $post_compression_cleanup == "true" ]]; then # Remove file(s) if requested
        if [[ "$file" == *".cue" ]]; then
          local cue_bin_files=$(grep -o -P "(?<=FILE \").*(?=\".*$)" "$file")
          local file_path=$(dirname "$(realpath "$file")")
          while IFS= read -r line
          do
            rm -f "$file_path/$line"
          done < <(printf '%s\n' "$cue_bin_files")
          rm -f $(realpath "$file")
        else
          rm -f "$(realpath "$file")"
        fi
      fi
    done
    ) |
    zenity --icon-name=net.retrodeck.retrodeck --progress --no-cancel --auto-close \
      --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
      --title "RetroDECK Configurator Utility - Compression in Progress"
      configurator_generic_dialog "The compression process is complete!"
      configurator_compress_games_dialog
  else
    configurator_compress_games_dialog
  fi
}

configurator_compress_all_games_dialog() {
  # This dialog compress all games found in all compatible roms folders into compatible formats

  local all_compressable_games=()
  local compressable_systems_list=$(cat $compression_targets | sed '/^$/d' | sed '/^\[/d')

  while IFS= read -r system # Find and validate all games that are able to be compressed with this compression type
  do
    compression_candidates=$(find "$roms_folder/$system" -type f -not -iname "*.txt")
    if [[ ! -z $compression_candidates ]]; then
      while IFS= read -r game
      do
        local compatible_compression_format=$(find_compatible_compression_format "$game")
        if [[ ! $compatible_compression_format == "none" ]]; then
          all_compressable_games=("${all_compressable_games[@]}" "$game")
        fi
      done < <(printf '%s\n' "$compression_candidates")
    fi
  done < <(printf '%s\n' "$compressable_systems_list")

  if [[ ! $(echo ${all_compressable_games[@]}) == "0" ]]; then
    local post_compression_cleanup=$(configurator_compression_cleanup_dialog)
    total_games_to_compress=${#all_compressable_games[@]}
    games_left_to_compress=$total_games_to_compress
    (
    for file in "${all_compressable_games[@]}"; do
      local compression_format=$(find_compatible_compression_format "$file")
      echo "# Compressing $(basename "$file") into $compression_format format" # Update Zenity dialog text
      progress=$(( 100 - (( 100 / "$total_games_to_compress" ) * "$games_left_to_compress" )))
      echo $progress
      games_left_to_compress=$((games_left_to_compress-1))
      compress_game "$compression_format" "$file"
      if [[ $post_compression_cleanup == "true" ]]; then # Remove file(s) if requested
        if [[ "$file" == *".cue" ]]; then
          local cue_bin_files=$(grep -o -P "(?<=FILE \").*(?=\".*$)" "$file")
          local file_path=$(dirname "$(realpath "$file")")
          while IFS= read -r line
          do
            rm -f "$file_path/$line"
          done < <(printf '%s\n' "$cue_bin_files")
          rm -f $(realpath "$file")
        else
          rm -f $(realpath "$file")
        fi
      fi
    done
    ) |
    zenity --icon-name=net.retrodeck.retrodeck --progress --no-cancel --auto-close \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator Utility - Compression in Progress"
    configurator_generic_dialog "The compression process is complete!"
    configurator_compress_games_dialog
  else
    configurator_generic_dialog "There were no games found that could be compressed."
  fi
}

configurator_compression_cleanup_dialog() {
  zenity --icon-name=net.retrodeck.retrodeck --question --no-wrap --cancel-label="No" --ok-label="Yes" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
  --title "RetroDECK Compression Cleanup" \
  --text="Do you want to remove old files after they are compressed?\n\nClicking \"No\" will leave all files behind which will need to be cleaned up manually and may result in game duplicates showing in the RetroDECK library."
  local rc=$? # Capture return code, as "Yes" button has no text value
  if [[ $rc == "0" ]]; then # If user clicked "Yes"
    echo "true"
  else # If "No" was clicked
    echo "false"
  fi
}

configurator_compress_games_dialog() {
  choice=$(zenity --list --title="RetroDECK Configurator Utility - Change Options" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --column="Choice" --column="Action" \
  "Compress Single Game" "Compress a single game into a compatible format" \
  "Compress Multiple Games - CHD" "Compress one or more games compatible with the CHD format" \
  "Compress Multiple Games - ZIP" "Compress one or more games compatible with the ZIP format" \
  "Compress Multiple Games - RVZ" "Compress one or more games compatible with the RVZ format" \
  "Compress Multiple Games - All Formats" "Compress one or more games compatible with any format" \
  "Compress All Games" "Compress all games into compatible formats" )

  case $choice in

  "Compress Single Game" )
    configurator_compress_single_game_dialog
  ;;

  "Compress Multiple Games - CHD" )
    configurator_compress_some_games_dialog "chd"
  ;;

  "Compress Multiple Games - ZIP" )
    configurator_compress_some_games_dialog "zip"
  ;;

  "Compress Multiple Games - RVZ" )
    configurator_compress_some_games_dialog "rvz"
  ;;

  "Compress Multiple Games - All Formats" )
    configurator_compress_some_games_dialog "all"
  ;;

  "Compress All Games" )
    configurator_compress_all_games_dialog
  ;;

  "" ) # No selection made or Back button clicked
    configurator_welcome_dialog
  ;;

  esac
}

configurator_check_multifile_game_structure() {
  local folder_games=($(find $roms_folder -maxdepth 2 -mindepth 2 -type d ! -name "*.m3u" ! -name "*.ps3"))
  if [[ ${#folder_games[@]} -gt 1 ]]; then
    echo "$(find $roms_folder -maxdepth 2 -mindepth 2 -type d ! -name "*.m3u" ! -name "*.ps3")" > $logs_folder/multi_file_games_"$(date +"%Y_%m_%d_%I_%M_%p").log"
    zenity --icon-name=net.retrodeck.retrodeck --info --no-wrap \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK" \
    --text="The following games were found to have the incorrect folder structure:\n\n$(find $roms_folder -maxdepth 2 -mindepth 2 -type d ! -name "*.m3u" ! -name "*.ps3")\n\nIncorrect folder structure can result in failure to launch games or saves being in the incorrect location.\n\nPlease see the RetroDECK wiki for more details!\n\nYou can find this list of games in ~/retrodeck/.logs"
  else
    configurator_generic_dialog "No incorrect multi-file game folder structures found."
  fi
  configurator_tools_and_troubleshooting_dialog
}

configurator_check_bios_files_basic() {
  configurator_generic_dialog "This check will look for BIOS files that RetroDECK has identified as working.\n\nThere may be additional BIOS files that will function with the emulators that are not checked.\n\nSome more advanced emulators such as Yuzu will have additional methods for verifiying the BIOS files are in working order."
  bios_checked_list=()

  while IFS="^" read -r bios_file bios_subdir bios_hash bios_system bios_desc
  do
    bios_file_found="No"
    bios_hash_matched="No"
    if [[ -f "$bios_folder/$bios_subdir$bios_file" ]]; then
      bios_file_found="Yes"
      if [[ $bios_hash == "Unknown" ]]; then
        bios_hash_matched="Unknown"
      elif [[ $(md5sum "$bios_folder/$bios_subdir$bios_file" | awk '{ print $1 }') == "$bios_hash" ]]; then
        bios_hash_matched="Yes"
      fi
    fi
    if [[ $bios_file_found == "Yes" && ($bios_hash_matched == "Yes" || $bios_hash_matched == "Unknown") && ! " ${bios_checked_list[*]} " =~ " ${bios_system} " ]]; then
      bios_checked_list=("${bios_checked_list[@]}" "$bios_system" )
    fi
  done < $bios_checklist
  systems_with_bios=${bios_checked_list[@]}

  configurator_generic_dialog "The following systems have been found to have at least one valid BIOS file.\n\n$systems_with_bios\n\nFor more information on the BIOS files found please use the Advanced check tool."

  configurator_tools_and_troubleshooting_dialog
}

configurator_check_bios_files_advanced() {
  configurator_generic_dialog "This check will look for BIOS files that RetroDECK has identified as working.\n\nNot all BIOS files are required for games to work, please check the BIOS description for more information on its purpose.\n\nThere may be additional BIOS files that will function with the emulators that are not checked.\n\nSome more advanced emulators such as Yuzu will have additional methods for verifiying the BIOS files are in working order."
  bios_checked_list=()

  while IFS="^" read -r bios_file bios_subdir bios_hash bios_system bios_desc
  do
    bios_file_found="No"
    bios_hash_matched="No"
    if [[ -f "$bios_folder/$bios_subdir$bios_file" ]]; then
      bios_file_found="Yes"
      if [[ $bios_hash == "Unknown" ]]; then
        bios_hash_matched="Unknown"
      elif [[ $(md5sum "$bios_folder/$bios_subdir$bios_file" | awk '{ print $1 }') == "$bios_hash" ]]; then
        bios_hash_matched="Yes"
      fi
    fi
    bios_checked_list=("${bios_checked_list[@]}" "$bios_file" "$bios_system" "$bios_file_found" "$bios_hash_matched" "$bios_desc")
  done < $bios_checklist

  zenity --list --title="RetroDECK Configurator Utility - Verify BIOS Files" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --column "BIOS File Name" \
  --column "System" \
  --column "BIOS File Found" \
  --column "BIOS Hash Match" \
  --column "BIOS File Description" \
  "${bios_checked_list[@]}"

  configurator_tools_and_troubleshooting_dialog
}

configurator_online_theme_downloader() {
  local online_themes=()
  local local_themes=()
  readarray -t online_themes < <(curl -s $es_themes_list | jq -r '.themeSets[] | "\(.name)\n\(.url)"')

  for (( i=0; i<${#online_themes[@]}; i+=2 )); do
    local name=${online_themes[$i]}
    local url=${online_themes[$i+1]}

    if [[ -d "$themes_folder/$(basename "$url" .git)" ]] || [[ -d "$rd_es_themes/$(basename "$url" .git)" ]]; then
      local_themes=("${local_themes[@]}" "true" "$name" "$url")
    else
      local_themes=("${local_themes[@]}" "false" "$name" "$url")
    fi
  done

  choice=$(zenity \
  --list --width=1200 --height=720 \
  --checklist --hide-column=3 --ok-label="Download/Update Themes" \
  --separator="," --print-column=3 \
  --text="Choose which themes to download:" \
  --column "Downloaded" \
  --column "Theme" \
  --column "Theme URL" \
  "${local_themes[@]}")

  local rc=$?
  if [[ $rc == "0" && ! -z $choice ]]; then
    (
    IFS="," read -ra chosen_themes <<< "$choice"
    for theme in "${chosen_themes[@]}"; do
      if [[ ! -d "$themes_folder/$(basename $theme .git)" ]] && [[ ! -d "$rd_es_themes/$(basename $theme .git)" ]]; then
        echo "# Downloading $(basename "$theme" .git)"
        git clone -q "$theme" "$themes_folder/$(basename $theme .git)"
      elif [[ -d "$themes_folder/$(basename $theme .git)" ]] && [[ ! -d "$rd_es_themes/$(basename $theme .git)" ]]; then
        cd "$themes_folder/$(basename $theme .git)"
        echo "# Checking $(basename $theme .git) for updates"
        git pull -fq
        cd "$rdhome"
      fi
    done
    ) |
    zenity --progress --pulsate \
    --icon-name=net.retrodeck.retrodeck \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title="Downloading Themes" \
    --no-cancel \
    --auto-close

    configurator_generic_dialog "The theme downloads and updates have been completed.\n\nYou may need to exit RetroDECK and start it again for the new themes to be available."
    configurator_tools_and_troubleshooting_dialog
  else
    configurator_tools_and_troubleshooting_dialog
  fi
}

configurator_rpcs3_firmware_updater() {
  configurator_generic_dialog "This tool will download firmware required by RPCS3 to emulate PS3 games.\n\nThe process will take several minutes, and the emulator will launch to finish the installation.\nPlease close RPCS3 manually once the installation is complete."
  (
    update_rpcs3_firmware
  ) |
    zenity --progress --pulsate \
    --icon-name=net.retrodeck.retrodeck \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title="Downloading PS3 Firmware" \
    --no-cancel \
    --auto-close
}

configurator_tools_and_troubleshooting_dialog() {
  choice=$(zenity --list --title="RetroDECK Configurator Utility - Change Options" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --column="Choice" --column="Action" \
  "Move RetroDECK Folders" "Move RetroDECK folders between internal/SD card or to a custom location" \
  "Multi-file game structure check" "Verify the proper structure of multi-file or multi-disc games" \
  "Basic BIOS file check" "Show a list of systems that BIOS files are found for" \
  "Advanced BIOS file check" "Show advanced information about common BIOS files" \
  "Compress Games" "Compress games to CHD format for systems that support it" \
  "Download PS3 Firmware" "Download PS3 firmware for use with the RPCS3 emulator" \
  "Install RetroDECK controller profile" "Install the custom RetroDECK controller profile and required icons" \
  "Install RetroDECK Starter Pack" "Install a small selection of classic games the RetroDECK creators picked themselves!" \
  "Backup RetroDECK Userdata" "Compress important RetroDECK user data folders" )

  case $choice in

  "Move RetroDECK Folders" )
    configurator_move_dialog
  ;;

  "Multi-file game structure check" )
    configurator_check_multifile_game_structure
  ;;

  "Basic BIOS file check" )
    configurator_check_bios_files_basic
  ;;

  "Advanced BIOS file check" )
    configurator_check_bios_files_advanced
  ;;

  "Compress Games" )
    configurator_compress_games_dialog
  ;;

  "Download PS3 Firmware" )
    if [[ $(check_network_connectivity) == "true" ]]; then
      configurator_rpcs3_firmware_updater
    else
      configurator_generic_dialog "You do not appear to currently have Internet access, which is required by this tool. Please try again when network access has been restored."
      configurator_tools_and_troubleshooting_dialog
    fi
  ;;

  "Install RetroDECK controller profile" )
    configurator_generic_dialog "Starting with version 0.7.0b, we are offering a new official RetroDECK controller profile!\nIt is an optional component that helps you get the most out of RetroDECK with a new in-game radial menu for unified hotkeys across emulators.\n\nThe files need to be installed outside of the normal ~/retrodeck folder, so we wanted your permission before proceeding.\n\nThe files will be installed at the following shared Steam locations:\n\n$HOME/.steam/steam/tenfoot/resource/images/library/controller/binding_icons/\n$HOME/.steam/steam/controller_base/templates/RetroDECK_controller_config.vdf"
    if [[ $(configurator_generic_question_dialog "RetroDECK Official Controller Profile" "Would you like to install the official RetroDECK controller profile?") == "true" ]]; then
      install_retrodeck_controller_profile
    fi
    configurator_generic_dialog "The RetroDECK controller profile install is complete.\nSee the Wiki for more details on how to use it to its fullest potential!"
    configurator_tools_and_troubleshooting_dialog
  ;;

  "Install RetroDECK Starter Pack" )
    install_retrodeck_starterpack
    configurator_generic_dialog "RetroDECK Configurator - Install RetroDECK Starter Pack" "The RetroDECK starter pack has been installed. We hope you enjoy it!"
    configurator_tools_and_troubleshooting_dialog
  ;;

  "Backup RetroDECK Userdata" )
    configurator_generic_dialog "This tool will compress important RetroDECK userdata (basically everything except the ROMs folder) into a zip file.\n\nThis process can take several minutes, and the resulting zip file can be found in the ~/retrodeck/backups folder."
    (
      backup_retrodeck_userdata
    ) |
    zenity --icon-name=net.retrodeck.retrodeck --progress --no-cancel --pulsate --auto-close \
            --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
            --title "RetroDECK Configurator Utility - Backup in Progress" \
            --text="Backing up RetroDECK userdata, please wait..."
    if [[ -f $backups_folder/$(date +"%0m%0d")_retrodeck_userdata.zip ]]; then
      configurator_generic_dialog "The backup process is now complete."
    else
      configurator_generic_dialog "The backup process could not be completed,\nplease check the logs folder for more information."
    fi
    configurator_tools_and_troubleshooting_dialog
  ;;

  "" ) # No selection made or Back button clicked
    configurator_welcome_dialog
  ;;

  esac
}

configurator_move_dialog() {
  choice=$(zenity --list --title="RetroDECK Configurator Utility - Move RetroDECK Folders" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --column="Choice" --column="Action" \
  "Move all of RetroDECK" "Move the entire retrodeck folder to a new location" \
  "Move ROMs folder" "Move only the ROMs folder to a new location" \
  "Move BIOS folder" "Move only the BIOS folder to a new location" \
  "Move Downloaded Media folder" "Move only the Downloaded Media folder to a new location" \
  "Move Saves folder" "Move only the Saves folder to a new location" \
  "Move States folder" "Move only the States folder to a new location" \
  "Move Themes folder" "Move only the Themes folder to a new location" \
  "Move Screenshots folder" "Move only the Screenshots folder to a new location" \
  "Move Mods folder" "Move only the Mods folder to a new location" \
  "Move Texture Packs folder" "Move only the Texture Packs folder to a new location" )

  case $choice in

  "Move all of RetroDECK" )
    configurator_move_folder_dialog "rdhome"
  ;;

  "Move ROMs folder" )
    configurator_move_folder_dialog "roms_folder"
  ;;

  "Move BIOS folder" )
    configurator_move_folder_dialog "bios_folder"
  ;;

  "Move Downloaded Media folder" )
    configurator_move_folder_dialog "media_folder"
  ;;

  "Move Saves folder" )
    configurator_move_folder_dialog "saves_folder"
  ;;

  "Move States folder" )
    configurator_move_folder_dialog "states_folder"
  ;;

  "Move Themes folder" )
    configurator_move_folder_dialog "themes_folder"
  ;;
  
  "Move Screenshots folder" )
    configurator_move_folder_dialog "screenshots_folder"
  ;;

  "Move Mods folder" )
    configurator_move_folder_dialog "mods_folder"
  ;;

  "Move Texture Packs folder" )
    configurator_move_folder_dialog "texture_packs_folder"
  ;;

  esac

  configurator_tools_and_troubleshooting_dialog
}

configurator_online_update_setting_dialog() {
  if [[ $(get_setting_value $rd_conf "update_check" retrodeck "options") == "true" ]]; then
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - RetroDECK Online Update Check" \
    --text="Online update checks for RetroDECK are currently enabled.\n\nDo you want to disable them?"

    if [ $? == 0 ] # User clicked "Yes"
    then
      set_setting_value $rd_conf "update_check" "false" retrodeck "options"
    else # User clicked "Cancel"
      configurator_developer_dialog
    fi
  else
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - RetroDECK Online Update Check" \
    --text="Online update checks for RetroDECK are currently disabled.\n\nDo you want to enable them?"

    if [ $? == 0 ] # User clicked "Yes"
    then
      set_setting_value $rd_conf "update_check" "true" retrodeck "options"
    else # User clicked "Cancel"
      configurator_developer_dialog
    fi
  fi
}

configurator_online_update_channel_dialog() {
  if [[ $(get_setting_value $rd_conf "update_repo" retrodeck "options") == "RetroDECK" ]]; then
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - RetroDECK Change Update Branch" \
    --text="You are currently on the production branch of RetroDECK updates. Would you like to switch to the cooker branch?\n\nAfter installing a cooker build, you may need to remove the \"stable\" branch install of RetroDECK to avoid overlap."

    if [ $? == 0 ] # User clicked "Yes"
    then
      set_setting_value $rd_conf "update_repo" "RetroDECK-cooker" retrodeck "options"
    else # User clicked "Cancel"
      configurator_developer_dialog
    fi
  else
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - RetroDECK Change Update Branch" \
    --text="You are currently on the cooker branch of RetroDECK updates. Would you like to switch to the production branch?\n\nAfter installing a production build, you may need to remove the \"cooker\" branch install of RetroDECK to avoid overlap."

    if [ $? == 0 ] # User clicked "Yes"
    then
      set_setting_value $rd_conf "update_repo" "RetroDECK" retrodeck "options"
    else # User clicked "Cancel"
      configurator_developer_dialog
    fi
  fi
}

configurator_retrodeck_multiuser_dialog() {
  if [[ $(get_setting_value $rd_conf "multi_user_mode" retrodeck "options") == "true" ]]; then
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - RetroDECK Multi-user Support" \
    --text="Multi-user support is current enabled. Do you want to disable it?\n\nIf there are more than one user configured,\nyou will be given a choice of which to use as the single RetroDECK user.\n\nThis users files will be moved to the default locations.\n\nOther users files will remain in the mutli-user-data folder.\n"

    if [ $? == 0 ] # User clicked "Yes"
    then
      multi_user_disable_multi_user_mode
    else # User clicked "Cancel"
      configurator_developer_dialog
    fi
  else
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - RetroDECK Multi-user support" \
    --text="Multi-user support is current disabled. Do you want to enable it?\n\nThe current users saves and states will be backed up and then moved to the \"retrodeck/multi-user-data\" folder.\nAdditional users will automatically be stored in their own folder here as they are added."

    if [ $? == 0 ]
    then
      multi_user_enable_multi_user_mode
    else
      configurator_developer_dialog
    fi
  fi
}

configurator_developer_dialog() {
  choice=$(zenity --list --title="RetroDECK Configurator Utility - Change Options" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --column="Choice" --column="Action" \
  "Change Multi-user mode" "Enable or disable multi-user support" \
  "Change Update Channel" "Change between normal and cooker builds" \
  "Change Update Check Setting" "Enable or disable online checks for new versions of RetroDECK" \
  "Browse the Wiki" "Browse the RetroDECK wiki online" )

  case $choice in

  "Change Multi-user mode" )
    configurator_retrodeck_multiuser_dialog
  ;;

  "Change Update Channel" )
    configurator_online_update_channel_dialog
  ;;

  "Change Update Check Setting" )
    configurator_online_update_setting_dialog
  ;;

  "Browse the Wiki" )
    xdg-open "https://github.com/XargonWan/RetroDECK/wiki"
  ;;

  "" ) # No selection made or Back button clicked
    configurator_welcome_dialog
  ;;
  esac
}

configurator_welcome_dialog() {
  if [[ $developer_options == "true" ]]; then
    welcome_menu_options=("RetroArch Presets" "Change RetroArch presets, log into RetroAchievements etc." \
    "Emulator Options" "Launch and configure each emulators settings (for advanced users)" \
    "Tools and Troubleshooting" "Move RetroDECK to a new location, compress games and perform basic troubleshooting" \
    "Reset" "Reset specific parts or all of RetroDECK" \
    "Developer Options" "Welcome to the DANGER ZONE")
  else
    welcome_menu_options=("RetroArch Presets" "Change RetroArch presets, log into RetroAchievements etc." \
    "Emulator Options" "Launch and configure each emulators settings (for advanced users)" \
    "Tools and Troubleshooting" "Move RetroDECK to a new location, compress games and perform basic troubleshooting" \
    "Reset" "Reset specific parts or all of RetroDECK" )
  fi

  choice=$(zenity --list --title="RetroDECK Configurator Utility" --cancel-label="Quit" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --width=1200 --height=720 \
  --column="Choice" --column="Action" \
  "${welcome_menu_options[@]}")

  case $choice in

  "RetroArch Presets" )
    configurator_retroarch_presets_dialog
  ;;

  "Dolphin Presets" )
    configurator_dolphin_presets_dialog
  ;;

  "Emulator Options" )
    configurator_power_user_warning_dialog
  ;;

  "Tools and Troubleshooting" )
    configurator_tools_and_troubleshooting_dialog
  ;;

  "Reset" )
    configurator_reset_dialog
  ;;

  "Developer Options" )
    configurator_generic_dialog "The following features and options are potentially VERY DANGEROUS for your RetroDECK install!\n\nThey should be considered the bleeding-edge of upcoming RetroDECK features, and never used when you have important saves/states/roms that are not backed up!\n\nYOU HAVE BEEN WARNED!"
    configurator_developer_dialog
  ;;

  esac
}

# START THE CONFIGURATOR

configurator_welcome_dialog
