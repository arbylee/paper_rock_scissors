How to use
==========

* bundle
* bundle exec ruby app/runner.rb
* Go to localhost:3000

When you first connect, you'll be dropped into a lobby where you can
chat.  Type "join" to start or join an existing game of RPS. When all
players have typed their throws, then the throws are revealed.  You can
connect to the server with multiple browser tabs.

Current design thoughts
=======================

The Game should be UI agnostic.  I think it would have some standard
interface, and possibly pass through JSON with messages or game data so
that the UIs can handle the drawing as needed.

As long as the game can stand alone in that way, we should be able to
write different server and UI implementations.  Right now it's a websocket
server.  That's probably good enough for what we want, but it leaves
options open.
