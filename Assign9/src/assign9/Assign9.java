
package assign9;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author kagom
 */
public class Assign9 {

  
    public static void main(String[] args) {
        try{
            String host = "DESKTOP-1RE2D49://localhost:3306"; // I don't know what to put here
            String username = "private_key.pem";
            String password = "public_key.pem";

            Connection connect = DriverManager.getConnection(host,username,password);
        }
        catch (SQLException err){
            System.out.println(err.getMessage());
        }
    }
    
}
