package triple6.gtthriftshop.models;

import java.util.ArrayList;

/**
 * Product.java
 * GTThriftShop
 *
 * Created by Wenzhong Jin on 7/16/17.
 * Copyright © 2017 Triple6. All rights reserved.
 */

class Product {
    private int userId;
    private String userName;
    private int pid;
    private String pName;
    private double pPrice;
    private String pInfo;
    private String postTime;
    private String usedTime;
    private boolean isSold;
    private ArrayList<String> imageURLs;

    public Product(int userId, String userName, int pid, String pName, double pPrice, String pInfo, String postTime,
                   String usedTime, boolean isSold, ArrayList<String> imageURLs) {
        this.userId = userId;
        this.userName = userName;
        this.pid = pid;
        this.pName = pName;
        this.pPrice = pPrice;
        this.pInfo = pInfo;
        this.postTime = postTime;
        this.usedTime = usedTime;
        this.isSold = isSold;
        this.imageURLs = imageURLs;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public int getPid() {
        return pid;
    }

    public void setPid(int pid) {
        this.pid = pid;
    }

    public String getpName() {
        return pName;
    }

    public void setpName(String pName) {
        this.pName = pName;
    }

    public double getpPrice() {
        return pPrice;
    }

    public void setpPrice(double pPrice) {
        this.pPrice = pPrice;
    }

    public String getpInfo() {
        return pInfo;
    }

    public void setpInfo(String pInfo) {
        this.pInfo = pInfo;
    }

    public String getPostTime() {
        return postTime;
    }

    public void setPostTime(String postTime) {
        this.postTime = postTime;
    }

    public String getUsedTime() {
        return usedTime;
    }

    public void setUsedTime(String usedTime) {
        this.usedTime = usedTime;
    }

    public boolean isSold() {
        return isSold;
    }

    public void setSold(boolean sold) {
        isSold = sold;
    }

    public ArrayList<String> getImageURLs() {
        return imageURLs;
    }

    public void setImageURLs(ArrayList<String> imageURLs) {
        this.imageURLs = imageURLs;
    }
}
