/*
 * article-list.vala
 * This file is part of news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with news. If not, see <http://www.gnu.org/licenses/>.
 */

namespace News.UI {
    [GtkTemplate (ui = "/org/gnome/News/ui/articlerow.ui")]
    public class ArticleList : Gtk.Box {
        public Post post { get; set; }
        
        [GtkChild (name = "title")]
        private Gtk.Label title;
        
        [GtkChild (name = "author")]
        private Gtk.Label author;
        
        [GtkChild (name = "date")]
        private Gtk.Label date;
        
        [GtkChild (name = "starred")]
        private Gtk.Button starred;
        
        public ArticleList (Post p) {
            this.get_style_context ().add_class ("feeds-list");
            set_post_data (p);

            this.show_all ();
        }

        public void set_post_data (Post post) {
            this.post = post;

            this.title.set_text(post.title);
            this.author.set_text(post.author);
            var date_str = post.date.format ("%d. %B");
            var now = new DateTime.now_local ();
            var diff = now.difference (this.post.date)/TimeSpan.DAY;
            
            if (diff == 0) date_str = "Today";
            else if (diff == 1) date_str = "Yesterday";
            
            this.date.set_text (date_str);
            
            if (post.starred) {
                starred.image = new Gtk.Image.from_icon_name ("starred-symbolic", Gtk.IconSize.MENU);
            }
        }
        
        [GtkCallback]
        private void star_article (Gtk.Button btn) {
            if (post.starred) {
                //unstar
                starred.image = new Gtk.Image.from_icon_name ("non-starred-symbolic", Gtk.IconSize.MENU);
            } else {
                //star
                starred.image = new Gtk.Image.from_icon_name ("starred-symbolic", Gtk.IconSize.MENU);
            }
            
            var app = GLib.Application.get_default() as Application;
            app.controller.mark_post_as_starred (post, !post.starred);
            post.starred = !post.starred;
        }
    }
}
