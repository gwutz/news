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
    
        public Gtk.FlowBox new_article_flow;
        public Gtk.ListBox new_article_list;
        private ArticleView article;
    
        [GtkChild (name = "ArticleView")]
        public Gtk.Viewport article_view;
        
        private bool is_flow = true;

        [GtkChild (name = "Stack")]
        private Gtk.Stack stack;

        [GtkChild (name = "ViewMode")]
        private Gtk.Button view_mode;
        
        [GtkChild (name = "BackButton")]
        private Gtk.Button back_btn;
        
        [GtkChild (name = "AddFeed")]
        private Gtk.MenuButton add_feed_btn;
        
        [GtkChild (name = "StackSwitcher")]
        private Gtk.StackSwitcher switcher;
        
        
        private Gtk.Widget previous_view = null;

        public Window (Application app) {
            Object (application: app);
            //stack.notify["visible-child"].connect (view_changed);
            var builder = new Gtk.Builder.from_resource ("/org/gnome/News/ui/article.ui");
            this.new_article_flow = builder.get_object("NewArticleFlow") as Gtk.FlowBox;
            article_view.add (new_article_flow);
            this.new_article_list = builder.get_object("NewArticleList") as Gtk.ListBox;
            view_mode.set_image (new Gtk.Image.from_icon_name ("view-list-symbolic", Gtk.IconSize.MENU));
            
            this.new_article_flow.child_activated.connect (show_article_flow);
            this.new_article_list.row_activated.connect (show_article_list);
            
            this.back_btn.clicked.connect (return_article);
        }

        /*private void view_changed() {

        }*/
        
        private void show_article_flow (Gtk.FlowBoxChild child) {
            Post post = ((PostImage)child.get_child()).post;
            show_article (post);
        }
        
        private void show_article_list (Gtk.ListBoxRow row) {
            Post post = ((ArticleList)row.get_child()).post;
            show_article (post);
        }
        
        private void show_article (Post post) {
            
            article = new ArticleView ();
            article.set_post (post);
            article.show ();
            this.previous_view = this.stack.get_visible_child ();
            this.stack.add_named (article, "feedview");
            this.stack.set_visible_child (article);
            set_headerbar_article ();
        }
        
        private void return_article (Gtk.Button btn) {
            
            this.stack.set_visible_child (this.previous_view);
            this.previous_view = null;
            this.stack.remove (this.article);
            this.article = null;
            set_headerbar_main ();
        }
        
        private void set_headerbar_article () {
            this.add_feed_btn.hide ();
            this.switcher.hide ();
            this.back_btn.show ();
        }
        
        private void set_headerbar_main () {
            this.add_feed_btn.show ();
            this.switcher.show ();
            this.back_btn.hide ();
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
