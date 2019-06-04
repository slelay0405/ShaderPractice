using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Company_AlphaTest : MonoBehaviour {

	public Transform TransDirectionalLight;
	public float rotSpeed = 5.0f;

	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
		TransDirectionalLight.Rotate (Vector3.up, rotSpeed * Time.deltaTime,Space.World);
	}
}
