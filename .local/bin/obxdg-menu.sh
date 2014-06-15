echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n" > ~/.config/openbox/xdg-menu.xml
echo -e "<openbox_menu xmlns=\"http://openbox.org/3.4/menu\">\n\n" >> ~/.config/openbox/xdg-menu.xml

xdg_menu --format openbox3 --root-menu /etc/xdg/menus/arch-applications.menu >> ~/.config/openbox/xdg-menu.xml

echo -e "\n\n</openbox_menu>\n" >> ~/.config/openbox/xdg-menu.xml

openbox --reconfigure
