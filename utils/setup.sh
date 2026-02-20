#Run this file w/ sudo 
while IFS= read -r package; do
  sudo pacman -S --noconfirm --needed "$package"
done < packages.txt

