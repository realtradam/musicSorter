#!/usr/bin/ruby
require 'ffruby'
require 'fileutils'

#Code written by Tradam --> https://github.com/realtradam

#Stores errors that happen
errors = Array.new
#Characters that are removed from the file/folder names as they are considered illegal in Windows
illegalCharacter = Array['/', '?', '\\', ':', '*', '"', '<', '>', '|']

songsDirectory = ARGV[0]#Where you want your organized songs to end up
if !Dir.exist?(songsDirectory)
	puts "Invalid Directory Given"
end

#All extensions you want considered and moved
fileExtensions = Array["mp3", "m4a", "wma"]#Note that .ogg files do not work, tags do not get read correctly
for extension in fileExtensions
	for song in Dir.glob("**/*." + extension)
		puts song
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
			errors.push("ERROR, TRACK NUMBER IS FOR: " + song)
			next
		end
	
		#Loads all the values we will want to use
		#Also removes any illegal characters in the string, will causes errors when making folders or filenames if they arent
		title = songData.title
		genre = songData.genre
		artist = songData.artist
		album = songData.album
		track = songData.track.to_s.split('/')[0]
		
		#Purges illegal characters
		for character in illegalCharacter
			title = title.delete character
			genre = genre.delete character
			artist = artist.delete character
			album = album.delete character
			track = track.delete character
		end
		
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
		
		#Check if the folder exists, if not make it
		#Once the folder is confirmed to exist, it will move and rename the song to the correct location
		begin
			if Dir.exist?(songsDirectory + songFolderGenre + songFolderArtist + songFolderAlbum)
				if !File.exist?(songsDirectory + songFolderGenre + songFolderArtist + songFolderAlbum + songFileName)
					FileUtils.mv song, songsDirectory + songFolderGenre + songFolderArtist + songFolderAlbum + songFileName
				else
					errors.push("ERROR, SONG ALREADY EXISTS AT " + songsDirectory + songFolderGenre + songFolderArtist + songFolderAlbum + songFileName + " CAN'T MOVE FROM " + song)
				end
			else
				FileUtils.mkdir_p(songsDirectory + songFolderGenre + songFolderArtist + songFolderAlbum)
				FileUtils.mv song, songsDirectory+ songFolderGenre + songFolderArtist + songFolderAlbum + songFileName
			end
		rescue Errno::ENOENT#Incase the program tries to save to a folder not yet created, shouldnt ever happen
			errors.push("ERROR, FILE OR FOLDER NAME ERROR AT " + song)
			next
		end
	end
end

#Prints out errors to the user, so they know what needs to be fixed
for error in errors
	puts error
end
