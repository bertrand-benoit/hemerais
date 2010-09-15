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

package hemera.tools;

import hemera.log.Log;
import hemera.utils.sound.SoundPlayer;

import java.io.FileNotFoundException;

/**
 * Hemera - Intelligent System Light pure java sound player.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 1.0.0
 */
public final class LightSoundPlayer {

	/****************************************************************************************/
	/*                                                                                      */
	/* Constants */
	/*                                                                                      */
	/****************************************************************************************/

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
	 * @param args
	 */
	public static final void main(final String[] args) {
		// Ensures at least one file sound path has been specified.
		if (args.length == 0) {
			System.err.println("usage: lightSoundPlayer <sound file path> [<sound file path> ... <sound file path>]");
			System.exit(1);
		}

		try {
			Log.utils.finest("Creating sound player");
			// Creates a sound player.
			final SoundPlayer soundPlayer = new SoundPlayer();
			Log.utils.finer("Created sound player");

			// For each specified sound file.
			Log.utils.fine("Managing specified sound file to play");
			for (final String soundFilePath : args) {
				try {
					soundPlayer.playFile(soundFilePath);
				} catch (final FileNotFoundException e) {
					Log.utils.warning("Unable to play '" + soundFilePath + "' (Message: " + e.getLocalizedMessage() + ").");
				}
			}
		} catch (final Exception e) {
			Log.utils.severe("An error occured while managing sound file to play (Message: " + e.getLocalizedMessage() + ").");
			Log.manageThrowable(e, 1);
		}
	}

}
