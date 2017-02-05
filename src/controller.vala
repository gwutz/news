/*
 * controller.vala
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

using Tracker;
namespace News {
    public class Controller : Object {
    
        public enum Updated {
            MARK_AS_READ
        }
    
        public signal void items_updated ();
        public signal void feeds_updated ();
        
        public signal void item_updated (Post post, Updated updated);
    
        private Sparql.Connection sparql;

        public Controller () {
            try {
                sparql = Sparql.Connection.get ();
            } catch ( Error e ){
                error (e.message);
            }
        }
        
        public List<Post> post_sorted_by_date (bool unread = false, bool starred = false) {
            StringBuilder builder = new StringBuilder ("
                SELECT 
                    nie:title(?msg) AS title
                    nmo:htmlMessageContent(?msg) AS content
                    nie:url(?msg) AS url
                    nco:fullname(?creator) AS fullname
                    nmo:isRead(?msg) AS is_read
                    ?msg BOUND(?tag) as is_starred
                    nie:contentCreated(?msg) AS date
                    nie:url(?website) AS ?author_homepage
                    nco:emailAddress(?email) AS author_email
                WHERE
                {
                    ?msg a mfo:FeedMessage");
                    
            if (unread) {
                builder.append ("; nmo:isRead false");
            }
            
            if (starred) {
                builder.append ("; nao:hasTag nao:predefined-tag-favorite ");
            }
            
            /*builder.append (". OPTIONAL {
                        ?msg nco:creator ?creator .
                        ?msg nao:hasTag ?tag .
                        FILTER(?tag = nao:predefined-tag-favorite) .
                        OPTIONAL {?creator nco:hasEmailAddress ?email } .
                        OPTIONAL {?creator nco:websiteUrl ?website }
                    }
                }
                ORDER BY DESC (nie:contentCreated(?msg))");*/
            builder.append("
                 . OPTIONAL { ?msg nao:hasTag ?tag .
                                FILTER(?tag = nao:predefined-tag-favorite)}
                 . OPTIONAL {
                    ?msg nco:creator ?creator
                    . OPTIONAL { ?creator nco:websiteUrl ?website }
                    . OPTIONAL { ?creator nco:hasEmailAddress ?email }
                }
            
            } ORDER BY DESC (nie:contentCreated(?msg))");
            var posts = new List<Post>();
            debug ("Query: %s", builder.str);
            try {                    
                var result = sparql.query (builder.str);

                while (result.next ()) {
                    posts.append(new Post(parse_cursor(result)));
                }
            } catch (Error e) {
                error (e.message);
            }
            
            return posts;
        }
        
        public List<Post> post_sorted_by_channel (string url) {
            string query = """
                SELECT
                  nie:title(?msg) AS title
                  nmo:htmlMessageContent(?msg) AS content
                  nie:url(?msg) AS url
                  nco:fullname(?creator) AS fullname
                  nmo:isRead(?msg) AS is_read
                  ?msg BOUND(?tag) as is_starred
                  nie:url(?website) AS author_homepage
                  nco:emailAddress(?email) AS author_email
                  nie:contentCreated(?msg) AS date
                  { ?msg a mfo:FeedMessage;
                         nmo:communicationChannel ?chan .
                    ?chan nie:url "%s" .
                    OPTIONAL { ?msg nao:hasTag ?tag .
                               FILTER(?tag = nao:predefined-tag-favorite) } .
                    OPTIONAL { ?msg nco:creator ?creator 
                        . OPTIONAL { ?creator nco:websiteUrl ?website }
                        . OPTIONAL { ?creator nco:hasEmailAddress ?email }
                    }
                    
                  }
                ORDER BY DESC (nie:contentCreated(?msg))
            """.printf (url);
            var posts = new List<Post>();
            try {            
                var result = sparql.query (query);
            
                while (result.next ()) {
                    posts.append(new Post(parse_cursor(result)));
                }
            } catch (Error e) {
                error (e.message);
            }
            
            return posts;
        }
        
        public List<Post> post_by_search (string text) {
            string query = """
                SELECT
                  nie:url(?msg) AS url
                  nie:title(?msg) AS title
                  nco:fullname(?creator) AS fullname
                  nie:url(?website) AS author_homepage
                  nie:contentCreated(?msg) AS date
                  nmo:htmlMessageContent(?msg) AS content
                  nmo:isRead(?msg) AS is_read
                  ?msg BOUND(?tag) as is_starred
                  { ?msg a mfo:FeedMessage;
                    fts:match "%s" .
                    OPTIONAL { ?msg nao:hasTag ?tag .
                                FILTER(?tag = nao:predefined-tag-favorite) } .
                    OPTIONAL { ?msg nco:creator ?creator .
                       OPTIONAL { ?creator nco:hasEmailAddress ?email } .
                       OPTIONAL { ?creator nco:websiteUrl ?website }
                    }
                  }
                ORDER BY fts:rank(?msg)""".printf (text);
            var posts = new List<Post>();
            debug ("%s", query);
            try {
                var result = sparql.query (query);
                while (result.next ()) {
                    posts.append(new Post(parse_cursor(result)));
                }
            } catch (Error e) {
                error (e.message);
            }
            return posts;
        }
        
        public void add_channel (string url, int update_interval = 5) {
            string query = """
                INSERT {
                  _:FeedSettings a mfo:FeedSettings ;
                                   mfo:updateInterval %i .
                  _:Feed a nie:DataObject, mfo:FeedChannel ;
                           mfo:feedSettings _:FeedSettings ;
                           nie:url "%s" }
            """.printf (update_interval, url);
            try {
                sparql.update (query);
            } catch (DBusError derror) {
                error ("There was an error to communicate with the dbus interface %s", derror.message);
            } catch (IOError ioerror) {
                error ("There was an error to communicate with the io interface %s", ioerror.message);
            } catch (Error err) {
                error ("A general error occurred %s", err.message);
            }
        }
        
        public void mark_post_as_read (Post post) {
            debug ("Url read: %s", post.url);
            string query = """
                DELETE
                  { ?msg nmo:isRead ?any }
                WHERE
                  { ?msg nie:url "%s";
                         nmo:isRead ?any }
                INSERT
                  { ?msg nmo:isRead true }
                WHERE
                  { ?msg nie:url "%s" }
            """.printf(post.url, post.url);
            try {
                sparql.update (query);
                item_updated (post, Updated.MARK_AS_READ);
            } catch (Error e) {
                error (e.message);
            }
        }
        
        public void mark_post_as_starred (Post post, bool starred) {
            debug ("Star article %s with url %s", post.title, post.url);
            string query;
            if (starred) {
                query = """
                    INSERT
                      { ?msg nao:hasTag nao:predefined-tag-favorite }
                    WHERE
                      { ?msg nie:url "%s" }
                    """.printf (post.url);
            } else {
                query = """
                    DELETE
                      { ?msg nao:hasTag nao:predefined-tag-favorite }
                    WHERE
                      { ?msg nie:url "%s";
                             nao:hasTag nao:predefined-tag-favorite }
                    """.printf (post.url);
            }
            try {
                sparql.update (query);
            } catch (Error e) {
                error (e.message);
            }
        }
        
        public List<Feed> get_feed_list () {
            string query = """
                SELECT
                  nie:url(?chan) AS url
                  nie:title(?chan) AS title
                  { 
                    ?chan a mfo:FeedChannel
                  }
                ORDER BY nie:title(?chan)
                """;
            var feeds = new List<Feed> ();
            try {
                var result = sparql.query (query);
                
                while (result.next ()) {
                    feeds.append (new Feed (parse_cursor (result)));
                }
            } catch (DBusError derror) {
                error ("There was an error to communicate with the dbus interface %s", derror.message);
            } catch (IOError ioerror) {
                error ("There was an error to communicate with the io interface %s", ioerror.message);
            } catch (Error err) {
                error ("A general error occurred %s", err.message);
            }
            return feeds; 
        }
        
        public void remove_channel (string url) {
        
            string messages = """
                DELETE
                    { ?msg a mfo:FeedMessage }
                WHERE
                    { 
                        ?msg nmo:communicationChannel ?chan .
                        ?chan nie:url "%s"
                    }
            """.printf (url);
            try {
                sparql.update (messages);
            } catch (Error e) {
                error (e.message);
            }
        
            string communicationChannel = """
                DELETE
                    { ?chan a rdfs:Resource }
                WHERE
                    { ?chan nie:url "%s" }
            """.printf (url);
            try {
                sparql.update (communicationChannel);
            } catch (Error e) {
                error (e.message);
            }
        }
        
        private HashTable<string, Value?> parse_cursor (Sparql.Cursor cursor) {
            HashTable<string, Value?> parsed_data = new HashTable<string, Value?> (str_hash, str_equal);
            var n_columns = cursor.n_columns;
            
            for (int i = 0; i < n_columns; i++) {
                var vtype = cursor.get_value_type (i);

                switch (vtype) {
                    case Sparql.ValueType.STRING:
                        parsed_data.insert (cursor.get_variable_name(i), cursor.get_string (i)); break;
                    case Sparql.ValueType.BOOLEAN:
                        parsed_data.insert (cursor.get_variable_name(i), cursor.get_boolean (i)); break;
                    case Sparql.ValueType.URI:
                        parsed_data.insert (cursor.get_variable_name(i), cursor.get_string (i)); break;
                    case Sparql.ValueType.INTEGER:
                        parsed_data.insert (cursor.get_variable_name(i), cursor.get_integer (i)); break;
                    case Sparql.ValueType.DOUBLE:
                        parsed_data.insert (cursor.get_variable_name(i), cursor.get_double (i)); break;
                    case Sparql.ValueType.DATETIME:
                        var tv = TimeVal();
                        tv.from_iso8601 (cursor.get_string (i));
                        parsed_data.insert (cursor.get_variable_name (i), new DateTime.from_timeval_local (tv));
                        break;
                    default:
                        var column = cursor.get_string (i);
                        if (column != null) {
                            parsed_data.insert (cursor.get_variable_name(i), cursor.get_string (i));
                        } else {
                            parsed_data.insert (cursor.get_variable_name(i), "");
                        }
                        break;
                }
            }
            
            return parsed_data;
        }

    }
}
