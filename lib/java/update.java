import java.sql.*;

public class update {
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
          int uptcnt = st.executeUpdate("update test.test_product set p_name='YYY' where p_id=1");

          /* 5) ��ʾ������� */
          System.out.print(uptcnt+" updated");

          /* 6) �ж���PostgreSQL������ */
          st.close();
          con.close();
     }
}