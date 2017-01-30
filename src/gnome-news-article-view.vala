/*
 * gnome-news-feed-view.vala
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

namespace GnomeNews {

    public class ArticleView : WebKit.WebView {
        
        public ArticleView (Post post) {
            Object ();
            
            var html = """
                <style>
                    h1,
                    h2,
                    h3 {
                      font-weight: bold;
                    }

                    h1 {
                      font-size: 1.6em;
                      line-height: 1.25em;
                    }

                    h2 {
                      font-size: 1.2em;
                      line-height: 1.51em;
                    }

                    h3 {
                      font-size: 1em;
                      line-height: 1.66em;
                    }

                    a {
                      text-decoration: underline;
                      font-weight: normal;
                    }

                    a,
                    a:visited,
                    a:hover,
                    a:active {
                      color: #0095dd;
                    }

                    * {
                      max-width: 100%;
                      height: auto;
                    }

                    p,
                    code,
                    pre,
                    blockquote,
                    ul,
                    ol,
                    li,
                    figure,
                    .wp-caption {
                      margin: 0 0 30px 0;
                    }

                    p > img:only-child,
                    p > a:only-child > img:only-child,
                    .wp-caption img,
                    figure img {
                      display: block;
                    }

                    .caption,
                    .wp-caption-text,
                    figcaption {
                      font-size: 0.9em;
                      line-height: 1.48em;
                      font-style: italic;
                    }

                    code,
                    pre {
                      white-space: pre-wrap;
                    }

                    blockquote {
                      padding: 0;
                      -webkit-padding-start: 16px;
                    }

                    ul,
                    ol {
                      padding: 0;
                    }

                    ul {
                      -webkit-padding-start: 30px;
                      list-style: disc;
                    }

                    ol {
                      -webkit-padding-start: 30px;
                      list-style: decimal;
                    }

                    /* Hide elements with common "hidden" class names */
                    .visually-hidden,
                    .visuallyhidden,
                    .hidden,
                    .invisible,
                    .sr-only {
                      display: none;
                    }

                    /* FeedView */

                    article {
                      overflow-y: hidden;
                      margin: 20px auto;
                      width: 640px;
                      color: #333;
                      font-family: Sans;
                      font-size: 18px;
                      word-wrap:break-word;
                    }

                    #footer {
                      font-size: 14px;
                      color: #777;
                    }

                    #footer a:link,
                    #footer a:active,
                    #footer a:visited {
                      text-decoration: none;
                      color: #777;
                    }

                    #footer a:hover {
                      text-decoration: underline;
                    }
                </style>
                <body>
                  <article>
                  <h1>%s</h1>
                  <span>%s</span>
                  <p>%s</p>
                  <div id="footer">
                </body>
            """.printf (post.title, post.author, post.content);
            
            load_html(html, null);
        }
    }

}
