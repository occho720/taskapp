//
//  ViewController.swift
//  taskapp
//
//  Created by 落合矩久 on 2021/05/23.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //　UIViewControllerは継承クラス。
    //　UITableViewDelegate, UITableViewDataSource は約束箱。「約束事があるんだ」と ViewControllerに言っている。
    
    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
        // 日付の近い順でソート：昇順
        // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskarray = try! Realm() .objacts(Task.self) .sorted(byKeyPath: "date", ascending: true)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        //　デリゲート任せる。約束事（表示内容、挙動など）を ViewControllerに表示する
    }
    
    //タスク一覧画面からタスク作成/編集画面へ遷移する時にデータであるTaskクラスを渡す処理を実装↓-
    // segue で画面遷移する時に呼ばれる
    // --- ここから ---
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self. tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
                
            }
            
            inputViewController.task = task
            
        }
    }
    // --- ここまで ---
    
    //タスク作成/編集画面から戻ってきた時に画面を更新する
    // --- ここから ---
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    // --- ここまで ---
    
    //　以下、プロトコルの指定メソッド（約束事）を実装しています。
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
   
    //内容はどうするの約束事。
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.  --- ここから ---
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let datestring:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = datestring
        // --- ここまで追加 ---
        
        return cell
    }
   
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellsegue", sender: nil)
    
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return . delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       // タスクを削除するときに通知をキャンセルする処理
        // --- ここから ---
        if editingStyle == .delete{
            // 削除するタスクを取得する
            let task = serf.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tabeView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in  requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        } // --- ここまで ---
        
    }
    

}

