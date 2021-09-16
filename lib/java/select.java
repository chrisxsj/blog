import java.sql.*;

public class select {
     public static void main(String[] args) throws Exception {

          /* 1) PostgreSQL��������Ϣ */
          Connection con; 
          Statement st;
          ResultSet rs;

          String url = "jdbc:postgresql://192.168.6.13:5433/test";
          String user = "test";
          String password = "test"; 

          /* 2) ����JDBC���� */
          Class.forName("org.postgresql.Driver");

          /* 3) ����PostgreSQL */
          con = DriverManager.getConnection(url, user, password);
          st = con.createStatement();

          /* 4) ִ��SELECT��� */
          rs = st.executeQuery("SELECT p_id,p_name,sale_price from test.test_product");

          /* 5) ��ʾ������� */
          while(rs.next()){
          /* System.out.print(rs.getInt("col_1")); */
          System.out.print(rs.getString("p_id")+", ");
          System.out.print(rs.getString("p_name")+", ");
          System.out.println(rs.getInt("sale_price"));
          }

          /* 6) �ж���PostgreSQL������ */
          rs.close(); 
          st.close();
          con.close();
     }
}