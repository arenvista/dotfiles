#Run this file w/ sudo 
while IFS= read -r package; do
  sudo pacman -S --noconfirm "$package"
done < packages.txt

