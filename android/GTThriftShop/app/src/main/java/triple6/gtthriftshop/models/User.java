package triple6.gtthriftshop.models;

/**
 * User.java
 * GTThriftShop
 *
 * Created by Wenzhong Jin on 7/16/17.
 * Copyright © 2017 Triple6. All rights reserved.
 */

class User {

    private int userId;
    private String nickName;
    private String email;
    private String avatarURL;
    private String description;
    private double rate;

    public User(int userId, String nickName, String email, String avatarURL, String description, double rate) {
        this.userId = userId;
        this.nickName = nickName;
        this.email = email;
        this.avatarURL = avatarURL;
        this.description = description;
        this.rate = rate;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAvatarURL() {
        return avatarURL;
    }

    public void setAvatarURL(String avatarURL) {
        this.avatarURL = avatarURL;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getRate() {
        return rate;
    }

    public void setRate(double rate) {
        this.rate = rate;
    }
}
