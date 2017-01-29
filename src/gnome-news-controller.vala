/*
 * gnome-news-controller.vala
 * This file is part of gnome-news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * gnome-news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * gnome-news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gnome-news. If not, see <http://www.gnu.org/licenses/>.
 */

using Tracker;
namespace GnomeNews {
    public class Controller : Object {
        private Sparql.Connection sparql;

        public Controller () {
            try {
                sparql = Sparql.Connection.get ();
            } catch ( Error e ){
                error (e.message);
            }
        }
        
        public List<Post> post_sorted_by_date () {
            string query = """
                SELECT 
                    nie:title(?msg) AS title
                    nmo:htmlMessageContent(?msg) AS content
                    nie:url(?msg) AS url
                    nco:fullname(?creator) AS fullname
                WHERE
                {
                    ?msg a mfo:FeedMessage
                }
                ORDER BY DESC (nie:contentCreated(?msg))
            """;
            var result = sparql.query (query);
            var posts = new List<Post>();
            while (result.next ()) {
                posts.append(new Post(result));
            }
            
            return posts;
        }

    }
}
