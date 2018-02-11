/******************************************************************************\
* Copyright (C) 2012-2016 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import com.leapmotion.leap.*;
import java.net.HttpURLConnection;
import java.net.URL;

class SampleListener extends Listener {
	
	public void onInit(Controller controller) {
        System.out.println("Initialized");
    }

    public void onConnect(Controller controller) {
        System.out.println("Connected");
    }

    public void onDisconnect(Controller controller) {
        //Note: not dispatched when running in a debugger.
        System.out.println("Disconnected");
    }

    public void onExit(Controller controller) {
        System.out.println("Exited");
    }

    public void onFrame(Controller controller) {
        // Get the most recent frame and report some basic information
        Frame frame = controller.frame();
        Frame prev = controller.frame(1);
        String myUrl, results;
        
        System.out.println("Frame id: " + frame.id()
            + ", timestamp: " + frame.timestamp()
            + ", hands: " + frame.hands().count()
            + ", fingers: " + frame.fingers().count());
        
        if (!frame.hands().isEmpty()) {
            System.out.println();
            
            if ((frame.hands().count() == 1) && (frame.hands().count() != prev.hands().count()))
            {
            	try
                {
                  myUrl = "http://6a64f579.ngrok.io/api/public/rate/" + 1;

                  results = doHttpUrlConnectionAction(myUrl);
                  System.out.println(results);
                }
                catch (Exception e)
                {
                  // deal with the exception in controller
                }
            	System.out.println("ONE --------------------------------------------------------------------");
            }
            else if ((frame.hands().count() == 2) && (frame.hands().count() != prev.hands().count()))
            {
            	try
                {
                  myUrl = "http://6a64f579.ngrok.io/api/public/rate/" + 2;

                  results = doHttpUrlConnectionAction(myUrl);
                  System.out.println(results);
                }
                catch (Exception e)
                {
                  // deal with the exception in controller
                }
            	System.out.println("TWO ----------------------------------------------------------------------");
            }
        }
        
    }
    
    private String doHttpUrlConnectionAction(String desiredUrl)
    		  throws Exception
	  {
	    URL url = null;
	    BufferedReader reader = null;
	    StringBuilder stringBuilder;
	
	    try
	    {
	      // create the HttpURLConnection
	      url = new URL(desiredUrl);
	      HttpURLConnection connection = (HttpURLConnection) url.openConnection();
	      
	      // just want to do an HTTP GET here
	      connection.setRequestMethod("GET");
	      
	      // uncomment this if you want to write output to this url
	      //connection.setDoOutput(true);
	      
	      // give it 15 seconds to respond
	      connection.setReadTimeout(15*1000);
	      connection.connect();
	
	      // read the output from the server
	      reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
	      stringBuilder = new StringBuilder();
	
	      String line = null;
	      while ((line = reader.readLine()) != null)
	      {
	        stringBuilder.append(line + "\n");
	      }
	      return stringBuilder.toString();
	    }
	    catch (Exception e)
	    {
	      e.printStackTrace();
	      throw e;
	    }
	    finally
	    {
	      // close the reader; this can throw an exception too, so
	      // wrap it in another try/catch block.
	      if (reader != null)
	      {
	        try
	        {
	          reader.close();
	        }
	        catch (IOException ioe)
	        {
	          ioe.printStackTrace();
	        }
	      }
	    }
	  }
}

class Sample {
    public static void main(String[] args) {
        // Create a sample listener and controller
        SampleListener listener = new SampleListener();
        Controller controller = new Controller();

        // Have the sample listener receive events from the controller
        controller.addListener(listener);

        // Keep this process running until Enter is pressed
        System.out.println("Press Enter to quit...");
        try {
            System.in.read();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // Remove the sample listener when done
        controller.removeListener(listener);
    }
}
