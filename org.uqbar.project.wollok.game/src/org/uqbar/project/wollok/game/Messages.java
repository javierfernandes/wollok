package org.uqbar.project.wollok.game;

import java.util.Properties;

import org.eclipse.osgi.util.NLS;
import org.uqbar.project.wollok.utils.WNLS;

public class Messages extends NLS {
	private static final String BUNDLE_NAME = "org.uqbar.project.wollok.game.messages"; //$NON-NLS-1$
	
	public static String WollokGame_NoMessage;
	public static String WollokGame_ObjectAlreadyInGame;
	
	public static String WollokGame_SoundGameNotStarted;
	public static String WollokGame_SoundAlreadyPlayed;
	public static String WollokGame_PausedOrResumedANotPlayedSound;
	public static String WollokGame_SoundAlreadyPaused;
	public static String WollokGame_VolumeOutOfRange;
	public static String WollokGame_SoundAlreadyPlaying;
	public static String WollokGame_SoundNotYetPlayed;
	
	public static String WollokGame_CharacterKeyNotFound;
	public static String WollokGame_ListenerNotFound;
	public static String WollokGame_AudioNotFound;
	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}
	
	public static Properties loadProperties() { return WNLS.load(BUNDLE_NAME, Messages.class); }

	private Messages() {
	}

}
