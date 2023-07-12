package JDBC;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.sql.Statement;
import java.util.Scanner;

public class vaseis_main {
	
	private Connection con;	
	
public vaseis_main() {
		try {
			Class.forName("org.postgresql.Driver");
			System.out.println("driver found");
		} catch (ClassNotFoundException e) {
			System.out.println("driver not found");
		}	
	}
	
	/**
	 * this function makes the connection to the database
	 */
	
	public void dbconnect(String fullAddress, String userName, String password) {
		try {
			con = DriverManager.getConnection(fullAddress,userName,password);
			System.out.println("successful connection");
		} catch (SQLException e) {
			System.out.println("unsuccessful connection");
		}	
	}
	
public void dbclose() {
		try {
			con.close();
			System.out.println("connection closed");
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
public void startTransactions() {
	try {
		con.setAutoCommit(false);
	} catch (SQLException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}	
}

public void commit() {
	try {
		con.commit();
	} catch (SQLException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
}
}

public void abort() {
	try {
		con.rollback();
	} catch (SQLException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}	
}

public void abort(Savepoint s) {	
	try {
		con.rollback(s);
	} catch (SQLException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
}

/**
 * @param typicalyear: this parameter indicates one of five years of studies
 * @param typicalseason: indicates the winter or spring semester
 * @param coursecode: indicates the code of the course to show the signed students at it
 * this function prints the students who are signed to a specific course according to year and semester chosen from user
 */
public void printSignedStudentsOf(int typicalyear, String typicalseason, String coursecode) {
	Statement st;
	try {
		st = con.createStatement();
		//ResultSet rs = st.executeQuery
				PreparedStatement ps;
				if(typicalseason.equals("winter")) {
					ps = con.prepareStatement("select s.name, s.surname from (\"Student\" s natural join \"participates\" par) join \"Course\" c using (course_code) where c.course_code =  ? and c.typical_year = ? and c.typical_season = 'winter';");
				}
else {
					ps = con.prepareStatement("select s.name, s.surname from (\"Student\" s natural join \"participates\" par) join \"Course\" c using (course_code) where c.course_code =  ? and c.typical_year = ? and c.typical_season = 'spring';");
				}
				ps.setString(1, coursecode);
				ps.setInt(2, typicalyear);
				ResultSet rs = ps.executeQuery();
		while(rs.next()) {
			System.out.println("name = "+rs.getString(1)+" surname = "+rs.getString(2));
		}
	} catch (SQLException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
}
/** 
 * @param typicalyear: this parameter indicates one of five years of studies
 * @param typicalseason: indicates the winter or spring semester
 * @param amka: indicates a unique student
 * this function prints data of grade for a specific student according to year and season chosen from user
 */
public void printStudetsGrade(int typicalyear,String typicalseason,int amka) {
	Statement st;
	Scanner sc1 = new Scanner(System.in);
	int cnt=1;
	try {
		st = con.createStatement();
		//ResultSet rs = st.executeQuery
		PreparedStatement ps2;
		if(typicalseason.equals("winter")) {
			ps2 = con.prepareStatement("select co.course_code, co.course_title, lab_grade, exam_grade\r\n" + 
					"from (\"Student\" s natural join \"Register\" reg) join \"Course\" co using(course_code)--participates\" par)\r\n" + 
					"where amka = ? and typical_year = ? and typical_season = 'winter'\r\n" + 
					"order by course_code");
		}else {
		ps2 = con.prepareStatement("select co.course_code, co.course_title, lab_grade, exam_grade\r\n" + 
				"from (\"Student\" s natural join \"Register\" reg) join \"Course\" co using(course_code)--participates\" par)\r\n" + 
				"where amka = ? and typical_year = ? and typical_season = 'spring'\r\n" + 
				"order by course_code");
		}
		ps2.setInt(1, amka);
		ps2.setInt(2, typicalyear);
		//ps2.setString(3, typicalseason);
		//ps2.setObject(3, typicalseason);
		ResultSet rs = ps2.executeQuery();
		while(rs.next()) {
			System.out.println((cnt++)+")  course code = "+rs.getString(1)+" course title = "+rs.getString(2)+" exam grade = "+rs.getFloat(4));
		}
		System.out.println("enter a number of index to change grades");
		int ind = sc1.nextInt();
		Statement st1 = con.createStatement();
		//ResultSet rs1 = st1.executeQuery
		PreparedStatement ps3;
		if(typicalseason.equals("winter")) {
		ps3= con.prepareStatement("select co.course_code, co.course_title, lab_grade, exam_grade\r\n" + 
				"from (\"Student\" s natural join \"Register\" reg) join \"Course\" co using(course_code)--participates\" par)\r\n" + 
				"where amka = ? and typical_year = ? and typical_season = 'winter'\r\n" + 
				"order by course_code");
		}else {
			ps3= con.prepareStatement("select co.course_code, co.course_title, lab_grade, exam_grade\r\n" + 
					"from (\"Student\" s natural join \"Register\" reg) join \"Course\" co using(course_code)--participates\" par)\r\n" + 
					"where amka = ? and typical_year = ? and typical_season = 'spring'\r\n" + 
					"order by course_code");
		}
		ps3.setInt(1, amka);
		ps3.setInt(2, typicalyear);
		//ps3.setObject(3, typicalseason);
		ResultSet rs1 = ps3.executeQuery();
		int cnt2=1;
		while(rs1.next() && cnt2 < ind) {
			cnt2++;
		}
		String coursecode = rs1.getString(1);
		String coursename = rs1.getString(2);
		int labgrade = rs1.getInt(3);
		int examgrade = rs1.getInt(4);
		System.out.println("code = "+coursecode+" course = "+coursename+" lab = "+labgrade+" exam = "+examgrade);
		Savepoint s1 = con.setSavepoint();
		System.out.println("enter a new grade for lab :");
		int numforlab = sc1.nextInt();
		if(numforlab == 0)
			return;
		else if(numforlab == -1)
			this.abort(s1);
		else {
			PreparedStatement ps = con.prepareStatement("update \"Register\"\r\n" + 
					"set lab_grade = ?\r\n" + 
					"where amka = ? and course_code = ? and exam_grade = ? and lab_grade = ?;");
			ps.setInt(1, numforlab);
			ps.setInt(2, amka);
			ps.setString(3, coursecode);
			ps.setInt(4, examgrade);
			ps.setInt(5, labgrade);
			ps.executeUpdate();
			System.out.println("done...lab grade changed");
		}
		
		Savepoint s2 = con.setSavepoint();
		System.out.println("enter a new grade for exam :");
		int numforexam = sc1.nextInt();
		if(numforexam == 0)
			return;
		else if(numforexam == -1)
			this.abort(s2);
		else {
			PreparedStatement ps1 = con.prepareStatement("update \"Register\"\r\n" + 
					"set exam_grade = ?\r\n" + 
					"where amka = ? and course_code = ? and exam_grade = ? and lab_grade = ?;");
			ps1.setInt(1, numforexam);
			ps1.setInt(2, amka);
			ps1.setString(3, coursecode);
			ps1.setInt(4, examgrade);
			ps1.setInt(5, numforlab);
			ps1.executeUpdate();

			System.out.println("done...exam grade changed");
		}
	} catch (SQLException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
}
	public static void main(String[] args) {
		vaseis_main vm = new vaseis_main();
		Scanner sc = new Scanner(System.in);
		while(true) {
		printMenu();
		System.out.println("choose an option");
		int ans=sc.nextInt();
		switch(ans) {
		case 1:
			System.out.println("enter ip address");
			String ipAddress = sc.next();
			System.out.println("enter database name");
			String databaseName = sc.next();
			System.out.println("enter username");
			String userName = sc.next();
			System.out.println("enter password");
			String password = sc.next();
			
			String fullAddress = ipAddress+databaseName;
			
		vm.dbconnect(fullAddress, userName, password);
		vm.startTransactions();
		break;
		
		case 2:
			vm.commit();
			vm.startTransactions();
			break;
			
		case 3:
			vm.abort();
			vm.startTransactions();
			break;
			
		case 4:
			System.out.println("enter the year:");
			 int year = sc.nextInt();
			 System.out.println("enter season");
			String season = sc.next();
			System.out.println("enter course code");
			String coursecode = sc.next();
			int i = sc.nextInt();
			coursecode = coursecode+" "+i;
			vm.printSignedStudentsOf(year,season, coursecode);
			break;
			
		case 5:
			System.out.println("enter amka of student:");
			int amka = sc.nextInt();
			System.out.println("enter the year:");
			int year1 = sc.nextInt();
			System.out.println("enter season");
			String season1 = sc.next();
			//if(season.equals("winter")) {
			vm.printStudetsGrade(year1,season1,amka);
			//}else {
				//vm.printStudetsGrade(year,semester_season_type.spring,amka);
			//}
			break;
		case 6:
			vm.dbclose();
			break;
		}
		}		
	}
	
	public enum semester_season_type {	
	winter, spring;
}
	
	public static void printMenu() {
		System.out.println("1) connect to a server postgresql");
		System.out.println("2) commit current transaction / start new");
		System.out.println("3) abort current transaction / start new");
		System.out.println("4) print signed students to a specific course");
		System.out.println("5) print student grade for a specific season");
		System.out.println("6) close connection");
	}
}
