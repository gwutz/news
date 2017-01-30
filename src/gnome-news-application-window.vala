/*
 * gnome-news-application-window.vala
 * This file is part of gnome news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * gnome news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * gnome news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gnome news. If not, see <http://www.gnu.org/licenses/>.
 */

namespace GnomeNews {

    [GtkTemplate (ui = "/org/gnome/News/ui/window.ui")]
    public class Window : Gtk.ApplicationWindow {
    
        [GtkChild (name = "ArticleView")]
        public Gtk.Viewport article_view;
        public Gtk.FlowBox new_article_flow;
        public Gtk.ListBox new_article_list;
        
        private bool is_flow = true;

        [GtkChild (name = "Stack")]
        private Gtk.Stack stack;

        [GtkChild (name = "ViewMode")]
        private Gtk.Button view_mode;
        
        private Gtk.Widget previous_view = null;

        public Window (Application app) {
            Object (application: app);
            //stack.notify["visible-child"].connect (view_changed);
            var builder = new Gtk.Builder.from_resource ("/org/gnome/News/ui/article.ui");
            this.new_article_flow = builder.get_object("NewArticleFlow") as Gtk.FlowBox;
            article_view.add (new_article_flow);
            this.new_article_list = builder.get_object("NewArticleList") as Gtk.ListBox;
            view_mode.set_image (new Gtk.Image.from_icon_name ("view-list-symbolic", Gtk.IconSize.MENU));
            
            this.new_article_flow.child_activated.connect (show_article);

        }

        /*private void view_changed() {

        }*/
        
        private void show_article (Gtk.FlowBoxChild child) {
            Post post = ((PostImage)child.get_child()).post;
            var articleview = new ArticleView (post);
            articleview.show ();
            this.previous_view = this.stack.get_visible_child ();
            this.stack.add_named (articleview, "feedview");
            this.stack.set_visible_child (articleview);
        }
        
        [GtkCallback]
        private void mode_switched () {
            if (is_flow) {
                view_mode.set_image (new Gtk.Image.from_icon_name ("view-grid-symbolic", Gtk.IconSize.MENU));
                this.article_view.remove (new_article_flow);
                this.article_view.add (new_article_list);
            } else {
                view_mode.set_image (new Gtk.Image.from_icon_name ("view-list-symbolic", Gtk.IconSize.MENU));
                this.article_view.remove (new_article_list);
                this.article_view.add (new_article_flow);
            }
            is_flow = !is_flow;
        }

    }
}
