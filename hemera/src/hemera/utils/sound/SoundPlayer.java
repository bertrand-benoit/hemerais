/*
 * Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
 * Copyright (C) 2010 Bertrand Benoit <projettwk@users.sourceforge.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses
 * or write to the Free Software Foundation,Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA 02110-1301  USA
 */

package hemera.utils.sound;

import hemera.log.Log;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.SourceDataLine;
import javax.sound.sampled.UnsupportedAudioFileException;

/**
 * Hemera - Intelligent System Simple (speech) sound player in pure Java.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 1.0.0
 */
public final class SoundPlayer {

	/****************************************************************************************/
	/*                                                                                      */
	/* Constants */
	/*                                                                                      */
	/****************************************************************************************/

	private static final int EXTERNAL_BUFFER_SIZE = 128000;

	/****************************************************************************************/
	/*                                                                                      */
	/* Attributes */
	/*                                                                                      */
	/****************************************************************************************/

	/****************************************************************************************/
	/*                                                                                      */
	/* Constructors */
	/*                                                                                      */
	/****************************************************************************************/

	/****************************************************************************************/
	/*                                                                                      */
	/* Getters / Setters */
	/*                                                                                      */
	/****************************************************************************************/

	/****************************************************************************************/
	/*                                                                                      */
	/* Specific methods */
	/*                                                                                      */
	/****************************************************************************************/

	/**
	 * Plays the sound whose file path is specified.
	 * 
	 * @param filePath
	 *            the path of the sound to play.
	 * @throws FileNotFoundException
	 * @throws HemeraSoundException
	 */
	public final void playFile(final String filePath) throws FileNotFoundException, HemeraSoundException {
		final File soundFile = new File(filePath);

		// Ensures it exists.
		if (!soundFile.exists()) {
			throw new FileNotFoundException("Sound file '" + filePath + "'.");
		}

		Log.utils.info(filePath + ": managed new sound file.");

		/*
		 * We have to read in the sound file.
		 */
		Log.utils.finer(filePath + ": opening audio output stream.");
		AudioInputStream audioInputStream = null;
		try {
			audioInputStream = AudioSystem.getAudioInputStream(soundFile);
			Log.utils.fine(filePath + ": opened audio output stream.");
		} catch (final UnsupportedAudioFileException e) {
			throw new HemeraSoundException("Unable to get audioInputStream.", e);
		} catch (final IOException e) {
			throw new HemeraSoundException("Unable to get audioInputStream.", e);
		}

		// Prepares SourceDataLine.
		final AudioFormat audioFormat = audioInputStream.getFormat();
		Log.utils.fine(filePath + ": format is " + audioFormat);
		SourceDataLine line = null;
		final DataLine.Info info = new DataLine.Info(SourceDataLine.class, audioFormat);
		try {
			// Gets a line, and then opens it.
			line = (SourceDataLine) AudioSystem.getLine(info);
			line.open(audioFormat);
		} catch (final LineUnavailableException e) {
			throw new HemeraSoundException("Unable to open sound source data line.", e);
		}

		// Activates it.
		Log.utils.finer(filePath + ": starting line.");
		line.start();

		// Reads (buffer) data from sound file, and writes them to data line.
		Log.utils.finer(filePath + ": starting reading.");
		int audioDataBytesRead = 0;
		final byte[] audioDataBuffer = new byte[EXTERNAL_BUFFER_SIZE];
		while (audioDataBytesRead != -1) {
			try {
				// Reads.
				audioDataBytesRead = audioInputStream.read(audioDataBuffer, 0, audioDataBuffer.length);

				// Writes to data line (if needed).
				if (audioDataBytesRead >= 0) {
					Log.utils.finest(filePath + ": read " + audioDataBytesRead + " bytes.");
					line.write(audioDataBuffer, 0, audioDataBytesRead);
				}
			} catch (final IOException e) {
				throw new HemeraSoundException("Error while reading sound file '" + filePath + "'.", e);
			}
		}

		// Waits until all data are managed.
		Log.utils.finer(filePath + ": draining line.");
		line.drain();

		// Finally closes the line.
		Log.utils.finer(filePath + ": closing line.");
		line.close();
		Log.utils.fine(filePath + ": closed.");
	}

	/****************************************************************************************/
	/*                                                                                      */
	/* Overrides */
	/*                                                                                      */
	/****************************************************************************************/

}
