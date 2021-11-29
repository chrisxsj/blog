package com.yf;

import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.NumberFormat;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MultiThreadProxyHubApiTest {

	static int count = 0;
    // 总访问量是clientNum，并发量是threadNum
    int threadNum = 500;
    int clientNum = 20000;

    float avgExecTime = 0;
    float sumexecTime = 0;
    long firstExecTime = Long.MAX_VALUE;
    long lastDoneTime = Long.MIN_VALUE;
    float totalExecTime = 0;

    public static void main(String[] args) {
        new MultiThreadProxyHubApiTest().run();
        System.out.println("finished!");
    }

    public void run() {

        final ConcurrentHashMap<Integer, ThreadRecord> records = new ConcurrentHashMap<Integer, ThreadRecord>();

        // 建立ExecutorService线程池，threadNum个线程可以同时访问
        ExecutorService exec = Executors.newFixedThreadPool(threadNum);
        // 模拟clientNum个客户端访问
        final CountDownLatch doneSignal = new CountDownLatch(clientNum);

        for (int i = 0; i < clientNum; i++) {
            Runnable run = new Runnable() {
                public void run() {
                    int index = getIndex();
                    long systemCurrentTimeMillis = System.currentTimeMillis();
                    try {
                    	insert_Bytes();
                        System.out.println(System.currentTimeMillis());

                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    records.put(index, new ThreadRecord(systemCurrentTimeMillis, System.currentTimeMillis()));
                    doneSignal.countDown();// 每调用一次countDown()方法，计数器减1
                }
            };
            exec.execute(run);
        }

        try {
            // 计数器大于0 时，await()方法会阻塞程序继续执行
            doneSignal.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        /**
         * 获取每个线程的开始时间和结束时间
         */
        for (int i : records.keySet()) {
            ThreadRecord r = records.get(i);
            sumexecTime += ((double) (r.endTime - r.startTime)) / 1000;

            if (r.startTime < firstExecTime) {
                firstExecTime = r.startTime;
            }
            if (r.endTime > lastDoneTime) {
                this.lastDoneTime = r.endTime;
            }
        }

        this.avgExecTime = this.sumexecTime / records.size();
        this.totalExecTime = ((float) (this.lastDoneTime - this.firstExecTime)) / 1000;
        NumberFormat nf = NumberFormat.getNumberInstance();
        nf.setMaximumFractionDigits(4);

        System.out.println("======================================================");
        System.out.println("线程数量:\t\t" + threadNum);
        System.out.println("客户端数量:\t" + clientNum);
        System.out.println("平均执行时间:\t" + nf.format(this.avgExecTime) + "秒");
        System.out.println("总执行时间:\t" + nf.format(this.totalExecTime) + "秒");
        System.out.println("吞吐量:\t\t" + nf.format(this.clientNum / this.totalExecTime) + "次每秒");
    }

    public static int getIndex() {
        return ++count;
    }

    
    class ThreadRecord {
        long startTime;
        long endTime;

        public ThreadRecord(long st, long et) {
            this.startTime = st;
            this.endTime = et;
        }

    }

    
    private static void insert_Bytes(){

		Connection ct=null;
		Statement sm=null;
		ResultSet rs=null;
		try{
			Class.forName("com.highgo.jdbc.Driver");
			ct=DriverManager.getConnection("jdbc:highgo://192.168.17.60:5456/highgo", "sysdba", "Hello@123");
			sm=ct.createStatement();
			String sql=" select * from test_process ";
			rs=sm.executeQuery(sql);
			
			while(rs.next()){
				System.out.println("rs.getString："+rs.getString("info"));
			}

		}catch (Exception e){
			e.printStackTrace();
		}

    }
	
}
