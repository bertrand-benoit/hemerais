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

import hemera.HemeraException;

/**
 * Hemera - Intelligent System
 * General sound exception.
 * 
 * @author Bertrand Benoit <projettwk@users.sourceforge.net>
 * @since 1.0.0
 */
public final class HemeraSoundException extends HemeraException {

	/****************************************************************************************/
	/*                                                                                      */
	/* Constants */
	/*                                                                                      */
	/****************************************************************************************/

	private static final long serialVersionUID = 6507541294655495516L;

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

	/**
     * 
     */
	public HemeraSoundException() {
		super();
	}

	/**
	 * @param message
	 */
	public HemeraSoundException(final String message) {
		super(message);
	}

	/**
	 * @param cause
	 */
	public HemeraSoundException(final Throwable cause) {
		super(cause);
	}

	/**
	 * @param message
	 * @param cause
	 */
	public HemeraSoundException(final String message, final Throwable cause) {
		super(message, cause);
	}
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

	/****************************************************************************************/
	/*                                                                                      */
	/* Overrides */
	/*                                                                                      */
	/****************************************************************************************/

}
