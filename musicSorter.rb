#!/usr/bin/ruby
require 'ffruby'
require 'fileutils'

#Code written by Tradam --> https://github.com/realtradam

#Stores errors when reading tags
errors = Array.new

#All extensions you want considered and moved
fileExtensions = Array["mp3", "m4a", "ogg", "wma"]
for extension in fileExtensions
	for song in Dir.glob("**/*." + extension)
		#Loads the tag of the song
		songData = FFruby::File.new(song)
		
		#Checks if any of the fields are not filled out
		#If they arent, save the song to an error log and skip it
		if songData.title == nil
			errors.push("ERROR, TITLE IS NIL FOR: " + song)
			next
		end
		if songData.genre == nil
			errors.push("ERROR, GENRE IS NIL FOR: " + song)
			next
		end
		if songData.artist == nil
			errors.push("ERROR, ARTIST IS NIL FOR: " + song)
			next
		end
		if songData.album == nil
			errors.push("ERROR, ALBUM IS NIL FOR: " + song)
			next
		end
		if songData.track == nil
			errors.push("ERROR, TRACK NUMBER IS NIL FOR: " + song)
			next
		end
	
		#Loads all the values we will want to use
		#Also removes any slashes in the string, will causes errors when making folders if they arent
		title = songData.title.delete '/'
		genre = songData.genre.delete '/'
		artist = songData.artist.delete '/'
		album = songData.album.delete '/'
		track = songData.track.to_s.split('/')[0]
		
		#Adds a slash to the end, to signify it is a folder and to simplify later code
		songFolderGenre = genre + "/"
		songFolderArtist = artist + "/"
		songFolderAlbum = album + "/"
		
		#Makes tracks sort nicely in file viewers(e.g changes track 3 into 03)
		if track.length == 1
			track = "0" + track
		end
		
		#How we want our songs to be formatted
		songFileName = track + title + "." + extension
		
		#Individually checking each folder if it exists, if not make it
		#Once the folder is confirmed to exist, it will move and rename the song to the correct location
		if Dir.exist?(songFolderGenre)
			if Dir.exist?(songFolderGenre + songFolderArtist)
				if Dir.exist?(songFolderGenre + songFolderArtist + songFolderAlbum)
					if !File.exist?(songFolderGenre + songFolderArtist + songFolderAlbum + songFileName)
						FileUtils.mv song, songFolderGenre + songFolderArtist + songFolderAlbum + songFileName
					end
				else
					Dir.mkdir(songFolderGenre + songFolderArtist + songFolderAlbum)
					FileUtils.mv song, songFolderGenre + songFolderArtist + songFolderAlbum + songFileName
				end
			else
				Dir.mkdir(songFolderGenre + songFolderArtist)
				Dir.mkdir(songFolderGenre + songFolderArtist + songFolderAlbum)
				FileUtils.mv song, songFolderGenre + songFolderArtist + songFolderAlbum + songFileName
			end
		else
			Dir.mkdir(songFolderGenre)
			Dir.mkdir(songFolderGenre + songFolderArtist)
			Dir.mkdir(songFolderGenre + songFolderArtist + songFolderAlbum)
			FileUtils.mv song, songFolderGenre + songFolderArtist + songFolderAlbum + songFileName
		end
	end
end

#Prints out errors to the user, so they know what needs to be fixed
for error in errors
	puts error
end